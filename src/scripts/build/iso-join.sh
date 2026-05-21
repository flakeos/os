#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  progname="$(basename "$0")"
  echo "Usage: $progname <iso-file>"
  echo ""
  echo "Reassemble split ISO parts into the original ISO."
  echo ""
  echo "Example: $progname flakeos-desktop.iso"
  exit 1
fi

iso="$1"
part_pattern="${iso}.part-"

shopt -s nullglob
parts=( ${part_pattern}* )
shopt -u nullglob

if [ ${#parts[@]} -eq 0 ]; then
  echo "Error: no parts found matching '${part_pattern}*'" >&2
  exit 1
fi

echo "Reassembling ${iso} from ${#parts[@]} parts..."
cat "${parts[@]}" > "$iso"
echo "Done: $(ls -lh "$iso")"
