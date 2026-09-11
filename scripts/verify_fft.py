#!/usr/bin/env python3
"""Bit-accurate reference check for fft_core_tb XSim output."""

from __future__ import annotations

import argparse
import csv
import math
from collections import defaultdict
from pathlib import Path


FFT_SIZE = 256
WIDTH = 16
FRACTION_BITS = 15
PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT = (
    PROJECT_ROOT / "FFT_Project.sim" / "sim_1" / "behav" / "xsim" / "fft_bins.csv"
)
DEFAULT_TWIDDLES = PROJECT_ROOT / "data" / "twiddle256_q15.coe"
EXPECTED_CASES = (
    "DC input (0.5)",
    "unit impulse",
    "cosine at bin 5",
    "complex tone at bin 17",
    "two-tone real input",
    "full-scale Nyquist input",
    "deterministic complex noise",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compare XSim FFT output with the bit-accurate fixed-point model."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--twiddles", type=Path, default=DEFAULT_TWIDDLES)
    return parser.parse_args()


def signed16(value: int) -> int:
    value &= 0xFFFF
    return value - 0x10000 if value & 0x8000 else value


def saturate16(value: int) -> int:
    return max(-32768, min(32767, value))


def bit_reverse8(value: int) -> int:
    return int(f"{value:08b}"[::-1], 2)


def load_twiddles(path: Path) -> list[tuple[int, int]]:
    text = path.read_text(encoding="utf-8")
    vector = text.split("memory_initialization_vector=", 1)[1].split(";", 1)[0]
    words = [int(token.strip(","), 16) for token in vector.split()]
    if len(words) != FFT_SIZE:
        raise ValueError(f"expected {FFT_SIZE} twiddles, found {len(words)}")
    return [(signed16(word >> 16), signed16(word)) for word in words]


def butterfly(
    x0: tuple[int, int], x1: tuple[int, int], twiddle: tuple[int, int]
) -> tuple[tuple[int, int], tuple[int, int]]:
    x0_re, x0_im = x0
    x1_re, x1_im = x1
    tw_re, tw_im = twiddle
    product_re = (x1_re * tw_re - x1_im * tw_im) >> FRACTION_BITS
    product_im = (x1_re * tw_im + x1_im * tw_re) >> FRACTION_BITS
    y0 = (
        saturate16((x0_re + product_re) >> 1),
        saturate16((x0_im + product_im) >> 1),
    )
    y1 = (
        saturate16((x0_re - product_re) >> 1),
        saturate16((x0_im - product_im) >> 1),
    )
    return y0, y1


def input_samples(case_name: str) -> list[tuple[int, int]]:
    samples: list[tuple[int, int]] = []
    for index in range(FFT_SIZE):
        if case_name == "DC input (0.5)":
            sample = (0x4000, 0)
        elif case_name == "unit impulse":
            sample = (0x7FFF if index == 0 else 0, 0)
        elif case_name == "cosine at bin 5":
            angle = 2.0 * math.pi * 5 * index / FFT_SIZE
            sample = (int(16384.0 * math.cos(angle)), 0)
        elif case_name == "complex tone at bin 17":
            angle = 2.0 * math.pi * 17 * index / FFT_SIZE
            sample = (
                int(12000.0 * math.cos(angle)),
                int(12000.0 * math.sin(angle)),
            )
        elif case_name == "two-tone real input":
            angle_5 = 2.0 * math.pi * 5 * index / FFT_SIZE
            angle_37 = 2.0 * math.pi * 37 * index / FFT_SIZE
            sample = (
                int(8192.0 * math.cos(angle_5) + 4096.0 * math.cos(angle_37)),
                0,
            )
        elif case_name == "full-scale Nyquist input":
            sample = (0x7FFF if index % 2 == 0 else -0x8000, 0)
        elif case_name == "deterministic complex noise":
            sample = (
                ((index * 25173 + 13849) & 0x3FFF) - 8192,
                ((index * 13849 + 25173) & 0x1FFF) - 4096,
            )
        else:
            raise ValueError(f"unknown test case: {case_name}")
        samples.append(sample)
    return samples


def reference_fft(
    samples: list[tuple[int, int]], twiddles: list[tuple[int, int]]
) -> list[tuple[int, int]]:
    memory = [(0, 0)] * FFT_SIZE
    for index, sample in enumerate(samples):
        memory[bit_reverse8(index)] = sample

    for stage in range(8):
        span = 1 << stage
        for butterfly_index in range(FFT_SIZE // 2):
            group = butterfly_index >> stage
            offset = butterfly_index & (span - 1)
            addr_x0 = (group << (stage + 1)) + offset
            addr_x1 = addr_x0 + span
            twiddle_addr = offset << (7 - stage)
            memory[addr_x0], memory[addr_x1] = butterfly(
                memory[addr_x0], memory[addr_x1], twiddles[twiddle_addr]
            )
    return memory


def approximate_magnitude(real: int, imag: int) -> int:
    maximum = max(abs(real), abs(imag))
    minimum = min(abs(real), abs(imag))
    return maximum + (minimum >> 2) + (minimum >> 3)


def load_actual(path: Path) -> dict[str, list[tuple[int, int, int, int]]]:
    actual: dict[str, list[tuple[int, int, int, int]]] = defaultdict(list)
    with path.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            actual[row["case_name"]].append(
                (
                    int(row["bin"]),
                    int(row["real"]),
                    int(row["imag"]),
                    int(row["magnitude"]),
                )
            )
    return dict(actual)


def main() -> None:
    args = parse_args()
    twiddles = load_twiddles(args.twiddles)
    actual_cases = load_actual(args.input)
    failures: list[str] = []

    missing_cases = set(EXPECTED_CASES) - set(actual_cases)
    unknown_cases = set(actual_cases) - set(EXPECTED_CASES)
    if missing_cases:
        failures.append("missing cases: " + ", ".join(sorted(missing_cases)))
    if unknown_cases:
        failures.append("unknown cases: " + ", ".join(sorted(unknown_cases)))

    for case_name in EXPECTED_CASES:
        if case_name not in actual_cases:
            continue
        rows = actual_cases[case_name]
        rows.sort(key=lambda row: row[0])
        if len(rows) != FFT_SIZE or [row[0] for row in rows] != list(range(FFT_SIZE)):
            failures.append(f"{case_name}: output bins are missing or duplicated")
            continue

        expected = reference_fft(input_samples(case_name), twiddles)
        mismatches = []
        for (bin_index, real, imag, magnitude), (expected_re, expected_im) in zip(
            rows, expected
        ):
            expected_magnitude = approximate_magnitude(expected_re, expected_im)
            if (real, imag) != (expected_re, expected_im):
                mismatches.append(
                    f"bin {bin_index}: got ({real},{imag}), "
                    f"expected ({expected_re},{expected_im})"
                )
            if magnitude != expected_magnitude:
                mismatches.append(
                    f"bin {bin_index}: magnitude {magnitude}, "
                    f"expected {expected_magnitude}"
                )

        if mismatches:
            failures.append(
                f"{case_name}: {len(mismatches)} mismatches\n  "
                + "\n  ".join(mismatches[:8])
            )
        else:
            print(f"PASS: {case_name} ({FFT_SIZE} bins exact)")

    if failures:
        raise SystemExit("\nFAIL:\n" + "\n".join(failures))
    print(f"PASS: {len(EXPECTED_CASES)} cases match the bit-accurate reference")


if __name__ == "__main__":
    main()
