#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat << EOF
Usage: $0 -i <source.mkv> -o <encoded.mkv> [-t <timestamp>]

Options:
  -i <path>       Source video file (Required)
  -o <path>       Encoded video file (Required)
  -t <timestamp>  Timestamp to extract (Default: 00:00:02)
  -h              Show this help message
EOF
  exit 1
}

SOURCE=""
ENCODED=""
TIMESTAMP="00:00:02"

while getopts "i:o:t:h" opt; do
  case "$opt" in
    i) SOURCE="$OPTARG" ;;
    o) ENCODED="$OPTARG" ;;
    t) TIMESTAMP="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [[ -z "$SOURCE" || -z "$ENCODED" ]]; then
  usage
fi

if [[ ! -f "$SOURCE" ]]; then
  echo "Error: Source file '$SOURCE' not found." >&2
  exit 1
fi

if [[ ! -f "$ENCODED" ]]; then
  echo "Error: Encoded file '$ENCODED' not found." >&2
  exit 1
fi

echo "==> Extracting source frame at $TIMESTAMP..."
ffmpeg -y -ss "$TIMESTAMP" -i "$SOURCE" -vframes 1 ./source_frame.png -loglevel error

echo "==> Extracting encoded frame at $TIMESTAMP..."
ffmpeg -y -ss "$TIMESTAMP" -i "$ENCODED" -vframes 1 ./encoded_frame.png -loglevel error

echo "==> Extracted:"
echo "    ./source_frame.png"
echo "    ./encoded_frame.png"
