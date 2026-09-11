# 256-Point Fixed-Point FFT Spectrum Visualizer

This project is a hardware spectrum visualizer built for the RealDigital Urbana FPGA board. It loads a 256-sample real-valued signal, computes an in-place radix-2 FFT in SystemVerilog, estimates the magnitude of each frequency bin, and renders the spectrum as a 640 x 480 bar graph over HDMI.

The design was created as a final project for ECE 385: Digital Systems Laboratory at the University of Illinois Urbana-Champaign by Kartik Pidaparthi and Kyle Stadler.

## Project status

This repository captures a functional educational prototype, including the FPGA top level, FFT datapath, display pipeline, IP configurations, constraints, and a behavioral diagnostic testbench.

The control path completes all eight FFT stages and the hardware demo produced a recognizable tone at bin 5 on the HDMI bar graph. The remaining limitation is numerical correctness: behavioral simulation still shows spurious energy and inconsistent bin amplitudes for simple DC, impulse, and single-tone inputs. The display is therefore useful as a proof of concept, but the FFT core should not be treated as a production-quality signal-processing block.

The latest debugging pass corrected two important timing problems: the direct butterfly input now travels through the same number of registers as the complex multiply, and the write addresses and valid signal are delayed to match BRAM, twiddle-ROM, and butterfly latency. That made the 256-point calculation complete consistently. The remaining artifacts most likely sit at the boundary between overlapping memory reads/writes, fixed-point truncation, and output ordering.

The complete board-level design also synthesizes successfully in Vivado 2022.2 with zero errors and zero critical warnings.

## My contribution

I, Kartik Pidaparthi, owned the FFT compute path and most of its verification. My work included:

- building the original 8-point radix-2 core and scaling it to 256 points;
- implementing the pipelined complex butterfly, stage address generator, dual-port complex sample memory, and FFT control FSM;
- integrating the Q1.15 twiddle-factor ROM and per-stage scaling;
- writing and iterating on the behavioral testbenches for DC, impulse, and single-tone inputs; and
- debugging pipeline alignment, write-back timing, and bit-reversed input/readout behavior.

Kyle Stadler owned most of the board-facing integration: the sample ROM and frame controller, magnitude-to-bar conversion, display buffer, VGA timing, HDMI output path, pin constraints, and hardware display tuning. We jointly debugged the integrated system and used the screen output to identify the remaining spectral artifacts.

## How it works

The core uses a decimation-in-time, radix-2 FFT. Input samples are placed in bit-reversed order, allowing the final spectrum to be read in linear bin order. A single pipelined butterfly is time-multiplexed across 128 butterfly operations per stage for eight stages.

Each sample component and twiddle factor is represented as a signed 16-bit value; twiddles use Q1.15 format. The butterfly keeps wider intermediate products, shifts the complex product back to Q1.15, and divides each write-back result by two. Scaling once per stage produces an overall factor of 1/256 and limits fixed-point overflow.

After the transform, the board controller approximates complex magnitude with

```text
|X[k]| ~= max(|re|, |im|) + 3/8 * min(|re|, |im|)
```

This multiplier-free approximation is inexpensive in hardware. The resulting 256 magnitudes are stored in a display buffer, mapped to vertical bars, and sent through a 25 MHz VGA timing pipeline and a 125 MHz TMDS serializer.

```text
sample ROM -> bit-reversed load -> in-place FFT -> magnitude estimate
                                                     |
HDMI output <- VGA timing <- bar renderer <- display buffer
```

## What we learned

- Pipeline bookkeeping is part of the algorithm. Data, twiddles, valid bits, and destination addresses must arrive on the same cycle.
- In-place transforms make memory scheduling critical. Reading the next butterfly while writing the previous result can silently corrupt a stage if the cadence is wrong.
- Bit reversal is an interface decision. Performing it on input, output, or both changes whether the visible spectrum appears in natural order.
- Fixed-point FFTs need an explicit overflow policy. Per-stage scaling protects the 16-bit storage format, but truncation and rounding affect the noise floor.
- A visually recognizable spectrum is useful integration evidence, but it is not a substitute for comparison against a numerical golden model.

## Repository layout

| Path | Contents |
| --- | --- |
| `rtl/` | Synthesizable SystemVerilog for the FFT, board controller, and display path |
| `dv/` | Behavioral simulation testbench |
| `data/` | Time-domain sample memory and Q1.15 twiddle coefficients |
| `constraints/` | Minimal Urbana clock, reset, and HDMI pin constraints |
| `ip/` | Vivado configuration files for the twiddle ROM, clock wizard, and HDMI transmitter |
| `third_party/` | Bundled RealDigital HDMI transmitter IP (BSD 3-Clause) |
| `scripts/` | Batch simulation helper |
| `FFT_Project.xpr` | Vivado 2022.2 project file |

Vivado caches, generated IP output products, run directories, simulation databases, and checkpoints are intentionally excluded. They can all be regenerated from the files above.

## Running the project

Requirements:

- AMD/Xilinx Vivado 2022.2
- RealDigital Urbana board, or another Spartan-7 target with updated constraints

To inspect or build the hardware design, open `FFT_Project.xpr` in Vivado. If prompted, generate output products for the three IP blocks before synthesis. The synthesis top is `top` and the target part is `xc7s50csga324-1`.

Run the behavioral diagnostic from the project directory with:

```powershell
vivado -mode batch -source scripts/run_sim.tcl
```

The testbench exercises DC, impulse, and bin-5 cosine inputs. It currently serves as a reproducible diagnostic for the known numerical artifacts rather than a passing golden-model regression.

Run a clean synthesis check with:

```powershell
vivado -mode batch -source scripts/run_synth.tcl
```

To visualize a different input signal on hardware, replace `data/samples.mem` with 256 signed 16-bit hexadecimal samples, one value per line, then regenerate the bitstream.

## Third-party IP

The HDMI/DVI encoder under `third_party/hdmi_tx_1.0/` is by Tinghui Wang / RealDigital.org and is distributed under the BSD 3-Clause terms included in its source headers. The remaining configured IP blocks are generated by Vivado.
