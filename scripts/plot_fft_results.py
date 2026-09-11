#!/usr/bin/env python3
"""Plot the bin data exported by fft_core_tb."""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT = (
    PROJECT_ROOT / "FFT_Project.sim" / "sim_1" / "behav" / "xsim" / "fft_bins.csv"
)
DEFAULT_OUTPUT = PROJECT_ROOT / "assets" / "fft-diagnostic.png"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Plot the diagnostic FFT output exported by the XSim testbench."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


def load_results(path: Path) -> dict[str, list[tuple[int, int]]]:
    results: dict[str, list[tuple[int, int]]] = defaultdict(list)
    with path.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            results[row["case_name"]].append(
                (int(row["bin"]), int(row["magnitude"]))
            )
    return dict(results)


def main() -> None:
    args = parse_args()
    results = load_results(args.input)
    case_order = ["DC input (0.5)", "unit impulse", "cosine at bin 5"]
    missing = [name for name in case_order if name not in results]
    if missing:
        raise SystemExit(f"missing simulation cases: {', '.join(missing)}")

    plt.rcParams.update(
        {
            "font.family": "DejaVu Sans",
            "axes.titleweight": "bold",
            "axes.edgecolor": "#94a3b8",
            "axes.labelcolor": "#dbeafe",
            "xtick.color": "#cbd5e1",
            "ytick.color": "#cbd5e1",
            "text.color": "#e2e8f0",
        }
    )
    figure, axes = plt.subplots(3, 1, figsize=(12, 8), sharex=True)
    figure.patch.set_facecolor("#07111f")
    figure.suptitle(
        "256-Point Fixed-Point FFT — Behavioral Diagnostic",
        fontsize=18,
        fontweight="bold",
        y=0.98,
    )

    subtitles = {
        "DC input (0.5)": "DC input",
        "unit impulse": "Unit impulse",
        "cosine at bin 5": "Cosine input at bin 5",
    }
    for axis, case_name in zip(axes, case_order):
        values = sorted(results[case_name])
        bins = [item[0] for item in values]
        magnitudes = [item[1] for item in values]
        peak_index = max(range(len(values)), key=lambda index: magnitudes[index])
        peak_bin = bins[peak_index]
        peak_magnitude = magnitudes[peak_index]

        axis.set_facecolor("#0b1728")
        axis.bar(bins, magnitudes, width=1.0, color="#22d3ee", linewidth=0)
        axis.scatter(
            [peak_bin], [peak_magnitude], color="#fbbf24", s=32, zorder=3
        )
        axis.annotate(
            f"observed peak: bin {peak_bin}",
            xy=(peak_bin, peak_magnitude),
            xytext=(10, -18),
            textcoords="offset points",
            color="#fbbf24",
            fontsize=9,
            ha="left" if peak_bin < 210 else "right",
        )
        if case_name == "cosine at bin 5":
            axis.axvline(5, color="#a78bfa", linewidth=1.2, linestyle="--")
            axis.axvline(251, color="#a78bfa", linewidth=1.2, linestyle="--")
            axis.text(
                8,
                axis.get_ylim()[1] * 0.78,
                "expected bins 5 and 251",
                color="#c4b5fd",
                fontsize=9,
            )

        axis.set_title(subtitles[case_name], loc="left", fontsize=12, pad=8)
        axis.set_ylabel("Magnitude")
        axis.grid(axis="y", color="#334155", alpha=0.65, linewidth=0.6)
        axis.set_axisbelow(True)
        axis.margins(x=0)

    axes[-1].set_xlabel("FFT bin")
    axes[-1].set_xlim(-1, 256)
    axes[-1].set_xticks(range(0, 257, 32))
    figure.text(
        0.5,
        0.012,
        "XSim output from fft_core_tb • plotted without numerical correction",
        ha="center",
        color="#94a3b8",
        fontsize=9,
    )
    figure.tight_layout(rect=(0.035, 0.04, 0.99, 0.95), h_pad=1.1)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    figure.savefig(args.output, dpi=160, bbox_inches="tight", facecolor=figure.get_facecolor())
    plt.close(figure)
    print(f"wrote {args.output}")


if __name__ == "__main__":
    main()
