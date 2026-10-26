# AV1 Encoding Workflow

A modular video encoding workflow built on top of [Av1an](https://github.com/rust-av/Av1an) and [SVT-AV1](https://gitlab.com/AOMediaCodec/SVT-AV1). Designed for cross-platform execution (macOS, Linux).

## Overview

This repository houses automation scripts and parameter profiles tailored for specific content types (animation, grainy film masters, standard live action), implementing guidelines from the [JET Encoding Guide](https://jaded-encoding-thaumaturgy.github.io/JET-guide/).

### Project Roadmap
- [x] Portable Av1an invocation scripts for macOS/Linux.
- [ ] Automated batch queue runner.
- [ ] Metric logging and inspection (VMAF, SSIMULACRA2).
- [ ] HDR10 / Dolby Vision metadata passthrough and tonemapping pipeline.
- [ ] Process prioritization and resource capping for background encoding.

---

## Prerequisites (macOS)

Install the core encoding toolchain via Homebrew:

```bash
brew install av1an svt-av1 ffmpeg mkvtoolnix vapoursynth
```

Verify the binaries are available in your `PATH`:
```bash
av1an --version
SvtAv1EncApp --version
ffmpeg -version
mkvmerge --version
```

---

## Directory Structure

```text
encoding/
├── animation.sh       # Script for 2D/3D animation & CGI content
├── .gitignore         # Excludes /out, /logs, and media files (*.mkv, *.mp4, *.y4m)
├── logs/              # (Ignored) Encoding logs and metrics
└── out/               # (Ignored) Completed encode outputs
```

---

## Usage

### 1. Animation & Clean CGI (`animation.sh`)

Tuned for flat colors, line-art integrity, and ringing reduction. Synthetic film grain is disabled to prevent speckle artifacts on clean vectors.

```bash
./animation.sh -i <input_clip> -o <output_clip>
```

**Parameters applied:**
- **Encoder:** `svt-av1`
- **Quality:** `--crf 24`
- **Preset:** `--preset 4` (High compression efficiency / detailed motion search)
- **Tuning:** `--tune 0` (Visual Quality / human psycho-visual perception)
- **Filters:** `--enable-restoration 1` (Wiener + SGR filters for line sharpness)
- **Grain:** `--film-grain 0` (Disabled)
- **Workers:** `-w 2` (2 scene workers running concurrently)

---

## Planned Scripts

| Script | Target Media | Key Parameters |
| :--- | :--- | :--- |
| `grainy.sh` | 35mm film, heavy analog grain | `--film-grain 12-24`, `--film-grain-denoise 1`, higher CRF |
| `live_action.sh` | Modern clean digital film / TV | `--film-grain 4-8`, standard visual tuning |
| `hdr_tonemap.sh` | 4K HDR10 / PQ sources | BT.2020 to Rec.709 tonemapping or HDR metadata passthrough |
