#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat << EOF
Usage: $0 -i <input_clip> -o <output_clip> [options]

Options:
  -i <path>       Input video file (Required)
  -o <path>       Output video file (Required)
  -d              Enable debanding filter (gradfun)
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

if [[ "$DEBAND" == true ]]; then
  echo "==> Deband filter enabled (gradfun=strength=1.5:radius=16)"
  EXTRA_ARGS+=("-f" "-vf gradfun=strength=1.5:radius=16")
fi

av1an -i "$INPUT" \
  "${EXTRA_ARGS[@]}" \
  -e svt-av1 \
  -v " --preset 4 --crf 24 --tune 0 --enable-restoration 1 --film-grain 0 " \
  -c mkvmerge \
  -w 2 \
  -o "$OUTPUT"
