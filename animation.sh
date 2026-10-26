#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -i <input_clip> -o <output_clip>"
  exit 1
}

INPUT=""
OUTPUT=""

while getopts "i:o:" opt; do
  case "$opt" in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
  usage
fi

av1an -i "$INPUT" \
  -e svt-av1 \
  -v " --preset 4 --crf 24 --tune 0 --enable-restoration 1 --film-grain 0 " \
  -c mkvmerge \
  -w 2 \
  -o "$OUTPUT"
