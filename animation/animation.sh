#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat << EOF
Usage: $0 -i <input_clip> -o <output_clip> [-m <mode>]

Modes:
  1   Baseline (No debanding, CRF 24) [~1.0MB / 10s]
      Fastest encode. Clean baseline, but gradients can show slight banding.
  2   Experimental Deband (gradfun + CRF 19 + aq-mode 0 + qm) [~1.7MB / 10s]
      Smooths gradients aggressively, but can soften fine line edges.
  3   Best Quality (Direct SVT-AV1, CRF 14, aq-mode 2) [~2.4MB / 10s] (Default)
      Pin-sharp line edges, fine 4x4 sub-partitions, smooth 10-bit internal gradient.

Options:
  -i <path>       Input video file (Required)
  -o <path>       Output video file (Required)
  -m <1|2|3>      Quality/deband preset mode (Default: 3)
  -h              Show this help message
EOF
  exit 1
}

INPUT=""
OUTPUT=""
MODE=3

while getopts "i:o:m:h" opt; do
  case "$opt" in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    m) MODE="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
  usage
fi

EXTRA_ARGS=()
SVT_PARAMS=""

case "$MODE" in
  1)
    echo "==> [Mode 1] Baseline (No debanding, CRF 24)"
    SVT_PARAMS="--preset 4 --crf 24 --tune 0 --enable-restoration 1 --film-grain 0"
    ;;
  2)
    echo "==> [Mode 2] Experimental Deband (gradfun dither, CRF 19, aq-mode 0, qm 1)"
    EXTRA_ARGS+=("-f" "-vf gradfun=strength=1.2:radius=16")
    SVT_PARAMS="--preset 4 --crf 19 --tune 0 --aq-mode 0 --enable-restoration 1 --enable-qm 1 --film-grain 0"
    ;;
  3)
    echo "==> [Mode 3] Best Quality (CRF 14, aq-mode 2, full edge resolution)"
    SVT_PARAMS="--preset 4 --crf 14 --tune 0 --aq-mode 2 --enable-restoration 1 --film-grain 0"
    ;;
  *)
    echo "Error: Invalid mode '$MODE'. Choose 1, 2, or 3." >&2
    usage
    ;;
esac

av1an -i "$INPUT" \
  ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"} \
  -e svt-av1 \
  -v " ${SVT_PARAMS} " \
  -c mkvmerge \
  -w 2 \
  -o "$OUTPUT"
