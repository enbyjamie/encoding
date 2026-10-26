#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat << EOF
Usage: $0 -i <input_clip> -o <output_clip> [options]

Options:
  -i <path>       Input video file (Required)
  -o <path>       Output video file (Required)
  -d              Enable debanding mode (gradfun dither + CRF 19 + aq-mode 2)
  -h              Show this help message
EOF
  exit 1
}

INPUT=""
OUTPUT=""
DEBAND=false

while getopts "i:o:dh" opt; do
  case "$opt" in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    d) DEBAND=true ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
  usage
fi

EXTRA_ARGS=()
CRF=24
EXTRA_SVT_PARAMS=""

if [[ "$DEBAND" == true ]]; then
  echo "==> Deband mode enabled (gradfun dither, CRF 19, Variance AQ)"
  EXTRA_ARGS+=("-f" "-vf gradfun=strength=1.2:radius=16")
  CRF=19
  EXTRA_SVT_PARAMS="--aq-mode 0 --enable-qm 1 "
fi

av1an -i "$INPUT" \
  ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"} \
  -e svt-av1 \
  -v " --preset 4 --crf ${CRF} --tune 0 ${EXTRA_SVT_PARAMS} --enable-restoration 1 --film-grain 0 " \
  -c mkvmerge \
  -w 2 \
  -o "$OUTPUT"

av1an -i sample_animation.mkv \
      -f "-vf gradfun=strength=1.2:radius=16" \
      -e svt-av1 \
      -v " --preset 4 --crf 19 --tune 0 --aq-mode 0 --enable-restoration 1 --enable-qm 1 --film-grain 0 " \
      -c mkvmerge -w 2 -o test_smooth_edge.mkv
