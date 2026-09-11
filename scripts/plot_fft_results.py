#!/usr/bin/env python3
"""Plot the verified FFT stimulus in time and its RTL spectrum in frequency.

The core testbench emits both CSV files.  Keeping the plotting step tied to
those files makes the figure a direct record of the simulation rather than a
separately regenerated example waveform.
"""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SIM_DIR = PROJECT_ROOT / "FFT_Project.sim" / "sim_1" / "behav" / "xsim"
DEFAULT_INPUTS = SIM_DIR / "fft_inputs.csv"
DEFAULT_OUTPUTS = SIM_DIR / "fft_bins.csv"
DEFAULT_FIGURE = PROJECT_ROOT / "assets" / "fft-diagnostic.png"
N = 256


def load_rows(path: Path, index_field: str, value_fields: tuple[str, ...]):
    rows: dict[str, list[dict[str, int]]] = defaultdict(list)
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            required = {"case_name", index_field, *value_fields}
            if not reader.fieldnames or not required.issubset(reader.fieldnames):
                raise ValueError(
                    f"{path} must contain columns {', '.join(sorted(required))}"
                )
            for row in reader:
                rows[row["case_name"]].append(
                    {field: int(row[field]) for field in (index_field, *value_fields)}
                )
    except FileNotFoundError as exc:
        raise SystemExit(
            f"Missing {path}. Run scripts/run_verify.ps1 before plotting."
        ) from exc
    return rows


def validate(rows: dict[str, list[dict[str, int]]], index_field: str) -> None:
    expected = list(range(N))
    for case_name, case_rows in rows.items():
        indices = sorted(row[index_field] for row in case_rows)
        if indices != expected:
            raise SystemExit(
                f"{case_name!r} has {len(indices)} {index_field} rows; expected 0..{N - 1}."
            )


def make_figure(inputs: dict, outputs: dict, destination: Path) -> None:
    cases = [
        (
            "cosine at bin 5",
            "Cosine input (time domain)",
            "Cosine output (frequency domain)",
            (5, 251),
        ),
        (
            "two-tone real input",
            "Two-tone input (time domain)",
            "Two-tone output (frequency domain)",
            (5, 37, 219, 251),
        ),
    ]
    missing = [name for name, *_ in cases if name not in inputs or name not in outputs]
    if missing:
        raise SystemExit(f"Input/output CSVs are missing paired cases: {', '.join(missing)}")

    plt.style.use("dark_background")
    figure, axes = plt.subplots(2, 2, figsize=(12, 8))
    figure.patch.set_facecolor("#0b1220")

    for row_index, (case_name, input_title, output_title, expected_bins) in enumerate(cases):
        input_rows = sorted(inputs[case_name], key=lambda row: row["sample"])
        output_rows = sorted(outputs[case_name], key=lambda row: row["bin"])

        input_axis, output_axis = axes[row_index]
        samples = [row["sample"] for row in input_rows]
        real_input = [row["real"] for row in input_rows]
        input_axis.plot(samples, real_input, color="#22d3ee", linewidth=1.35)
        input_axis.axhline(0, color="#64748b", linewidth=0.7, alpha=0.7)
        input_axis.set_title(input_title, loc="left", fontsize=11, weight="bold")
        input_axis.set_xlabel("Sample n")
        input_axis.set_ylabel("Amplitude (Q1.15)")
        input_axis.set_xlim(0, N - 1)
        input_axis.grid(alpha=0.16)

        bins = [row["bin"] for row in output_rows]
        magnitudes = [row["magnitude"] for row in output_rows]
        output_axis.bar(bins, magnitudes, width=1.0, color="#f59e0b", alpha=0.9)
        for expected_bin in expected_bins:
            output_axis.axvline(
                expected_bin, color="#fb7185", linewidth=0.9, linestyle="--", alpha=0.8
            )
        output_axis.set_title(output_title, loc="left", fontsize=11, weight="bold")
        output_axis.set_xlabel("FFT bin k")
        output_axis.set_ylabel("Magnitude")
        output_axis.set_xlim(0, N - 1)
        output_axis.grid(alpha=0.16, axis="y")

    figure.suptitle(
        "256-point fixed-point FFT: verified time-domain input → frequency-domain output",
        fontsize=15,
        weight="bold",
        color="#f8fafc",
    )
    figure.text(
        0.5,
        0.018,
        "RTL stimulus and FFT bins exported by fft_core_tb | 1,792 complex bins match the bit-accurate reference",
        ha="center",
        color="#cbd5e1",
        fontsize=9,
    )

    figure.tight_layout(rect=(0, 0.06, 1, 0.94))
    destination.parent.mkdir(parents=True, exist_ok=True)
    figure.savefig(destination, dpi=170, facecolor=figure.get_facecolor())
    plt.close(figure)
    print(f"Wrote {destination}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--inputs", type=Path, default=DEFAULT_INPUTS)
    parser.add_argument("--outputs", type=Path, default=DEFAULT_OUTPUTS)
    parser.add_argument("--output", type=Path, default=DEFAULT_FIGURE)
    args = parser.parse_args()

    inputs = load_rows(args.inputs, "sample", ("real", "imag"))
    outputs = load_rows(args.outputs, "bin", ("real", "imag", "magnitude"))
    validate(inputs, "sample")
    validate(outputs, "bin")
    make_figure(inputs, outputs, args.output)


if __name__ == "__main__":
    main()
