# Animation Encoding Profile

Targeted profile for 2D/3D animation, anime, and digital CGI content. Tuned for clean lines, flat gradient preservation, and zero artificial noise.

## Script Usage

```bash
./animation.sh -i <input_clip> -o <output_clip> [-d]
```

### Options
* `-i <path>`: Source video file (Required).
* `-o <path>`: Output video file path (Required).
* `-d`: Enable debanding mode (`gradfun=strength=1.2:radius=16`, drops to `--crf 19`, disables delta-QP with `--aq-mode 0`, and applies `--enable-qm 1`). Use this when source masters exhibit visible color banding in gradients (e.g. skies, snow, fog).
* `-h`: Display help.

---

## Encoder Profile Details

* **Encoder:** `svt-av1` via `av1an` chunking.
* **CRF:** `24` by default. Automatically shifts to `19` when `-d` (debanding) is active to prevent dither quantization/blocking.
* **Preset:** `4` (Optimized search partitions and motion vector estimation).
* **Tuning:** `--tune 0` (Visual Quality).
* **Restoration:** `--enable-restoration 1` (Wiener + SGR in-loop filters to prevent line-art ringing).
* **Film Grain:** `--film-grain 0` (Disabled to avoid synthetic noise on clean vector art).
* **Deband Mode (`-d`):** Injects `-vf gradfun=strength=1.2:radius=16`, sets `--crf 19`, sets `--aq-mode 0` to prevent macroblock boundary starvation on silhouettes, and sets `--enable-qm 1` (quantization matrices) to eliminate high-contrast line ringing.

---

## Visual Inspection (`get_frames.sh`)

Extracts identical frames from both source and encoded clips to compare compression quality, debanding, and line preservation:

```bash
../get_frames.sh -i <source.mkv> -o <encoded.mkv> [-t <timestamp>]
```

### Options
* `-i <path>`: Source video file (Required).
* `-o <path>`: Encoded video file (Required).
* `-t <timestamp>`: Extraction timestamp (Default: `00:00:02`). Supports formats like `2s`, `00:00:05`, etc.
* Outputs `./source_frame.png` and `./encoded_frame.png` for side-by-side inspection.
