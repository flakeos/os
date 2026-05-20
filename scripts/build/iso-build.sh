#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_DIR="${PROJECT_DIR}/dist"
NIXPKGS_ALLOW_BROKEN="${NIXPKGS_ALLOW_BROKEN:-1}"

cd "${PROJECT_DIR}"
mkdir -p "${OUTPUT_DIR}"

build_iso() {
  local target="$1"
  local name="$2"

  echo "Building ${target} -> ${name}..."

  NIXPKGS_ALLOW_BROKEN="${NIXPKGS_ALLOW_BROKEN}" \
    sudo --preserve-env=NIXPKGS_ALLOW_BROKEN \
    nix build --impure "${target}"

  local result_dir result_iso
  result_dir="$(readlink -f result)"
  result_iso=$(find "${result_dir}" -name "*.iso" -type f | head -1)

  if [ -z "${result_iso}" ]; then
    echo "ERROR: ISO not found in build result for ${target}"
    find "${result_dir}" -type f | head -20
    exit 1
  fi

  cp "${result_iso}" "${OUTPUT_DIR}/${name}"
  chmod 644 "${OUTPUT_DIR}/${name}"
  ls -lh "${OUTPUT_DIR}/${name}"
}

build_iso '.#packages.x86_64-linux.iso-minimal' 'flakeos-minimal.iso'
build_iso '.#packages.x86_64-linux.iso-desktop' 'flakeos-desktop.iso'
build_iso '.#packages.x86_64-linux.iso-laptop' 'flakeos-laptop.iso'
build_iso '.#packages.x86_64-linux.iso-server' 'flakeos-server.iso'

echo ""
echo "All ISOs built in ${OUTPUT_DIR}:"
ls -lh "${OUTPUT_DIR}"/flakeos-*.iso
