# AV1 Encoding Workflow

A modular video encoding workflow built on top of [Av1an](https://github.com/rust-av/Av1an) and [SVT-AV1](https://gitlab.com/AOMediaCodec/SVT-AV1). Designed for cross-platform execution (macOS, Linux).

## Overview

This repository houses automation scripts and parameter profiles tailored for specific content types (animation, grainy film masters, standard live action), implementing guidelines from the [JET Encoding Guide](https://jaded-encoding-thaumaturgy.github.io/JET-guide/).

### Project Roadmap
- [x] Optimised animation encoding.
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
├── animation/
│   └── animation.sh   # Script for 2D/3D animation & CGI content
├── .gitignore         # Excludes /out, /logs, and media files (*.mkv, *.mp4, *.png)
├── logs/              # (Ignored) Encoding logs and metrics
└── out/               # (Ignored) Completed encode outputs
```

---

## Usage

### 1. Animation & Clean CGI (`animation/animation.sh`)

Tuned for flat colors, line-art integrity, and ringing reduction. Features three selectable preset modes via `-m`:

```bash
./animation/animation.sh -i <input_clip> -o <output_clip> [-m <1|2|3>]
```

**Preset Modes:**
- **Mode 1 (Baseline / No Deband):** `--crf 24`, fast compression (`~1.0MB / 10s`).
- **Mode 2 (Experimental Deband):** `-vf gradfun=strength=1.2:radius=16`, `--crf 19`, `--aq-mode 0`, `--enable-qm 1` (`~1.7MB / 10s`).
- **Mode 3 (Best Quality - Default):** `--crf 14`, `--aq-mode 2`, `--enable-restoration 1`, full 4x4 sub-partitioning (`~2.4MB / 10s`). Maintains pin-sharp edges and 10-bit smooth gradients without pre-filter blurring.

---

## Planned Scripts

| Script | Target Media | Key Parameters |
| :--- | :--- | :--- |
| `grainy.sh` | 35mm film, heavy analog grain | `--film-grain 12-24`, `--film-grain-denoise 1`, higher CRF |
| `live_action.sh` | Modern clean digital film / TV | `--film-grain 4-8`, standard visual tuning |
| `hdr_tonemap.sh` | 4K HDR10 / PQ sources | BT.2020 to Rec.709 tonemapping or HDR metadata passthrough |
