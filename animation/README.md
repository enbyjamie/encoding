# Animation Encoding Profile

Targeted profile for 2D/3D animation, anime, and digital CGI content. Tuned for clean lines, flat gradient preservation, and zero artificial noise.

## Script Usage

```bash
./animation.sh -i <input_clip> -o <output_clip> [-m <1|2|3>]
```

### Options
* `-i <path>`: Source video file (Required).
* `-o <path>`: Output video file path (Required).
* `-m <mode>`: Quality & deband profile preset (Default: `3`).
* `-h`: Display help.

---

## Preset Modes

| Mode | Name | Target Output Size | SVT-AV1 & Pre-filter Parameters | Characteristics |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **Baseline (No Deband)** | **~1.0 MB** *(from 51MB source)* | `--crf 24`, `--tune 0`, `--enable-restoration 1` | Fastest encode. Clean lines, but flat gradients (snow/skies) may show source banding. |
| **2** | **Experimental Deband** | **~1.7 MB** *(from 51MB source)* | `-vf gradfun=strength=1.2:radius=16`<br>`--crf 19`, `--aq-mode 0`, `--enable-qm 1` | Smooths harsh gradient banding, but introduces edge softening and corner-stepping. |
| **3** | **Best Quality (Default)** | **~2.4 MB** *(from 51MB source)* | `--crf 14`, `--aq-mode 2`, `--enable-restoration 1` | **Recommended.** Pin-sharp line-art, 4x4 sub-block partitions, smooth internal 10-bit gradient interpolation without pre-filter blurring. |

---

## Visual Inspection (`get_frames.sh`)

Extracts identical frames from both source and encoded clips to compare compression quality, debanding, and line preservation:

```bash
../get_frames.sh -i <source.mkv> -o <encoded.mkv> [-t <timestamp>]
```

* Outputs `./source_frame.png` and `./encoded_frame.png` for side-by-side inspection.
