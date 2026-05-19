#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_DIR="${PROJECT_DIR}/dist"
ISO_NAME="${ISO_NAME:-bora.iso}"
BUILD_TARGET="${BUILD_TARGET:-.#packages.x86_64-linux.iso-minimal}"
NIXPKGS_ALLOW_BROKEN="${NIXPKGS_ALLOW_BROKEN:-1}"

cd "${PROJECT_DIR}"
NIXPKGS_ALLOW_BROKEN="${NIXPKGS_ALLOW_BROKEN}" \
sudo --preserve-env=NIXPKGS_ALLOW_BROKEN \
  nix build --impure "${BUILD_TARGET}"

RESULT_DIR="$(readlink -f result)"
ISO_PATH="${RESULT_DIR}/iso/${ISO_NAME}"

if [ ! -f "${ISO_PATH}" ]; then
  echo "ISO not found at ${ISO_PATH}, searching..."
  ISO_PATH=$(find "${RESULT_DIR}" -name "*.iso" -type f | head -1)
fi

if [ -z "${ISO_PATH}" ] || [ ! -f "${ISO_PATH}" ]; then
  echo "ERROR: ISO not found in build result"
  find "${RESULT_DIR}" -type f | head -20
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cp "${ISO_PATH}" "${OUTPUT_DIR}/${ISO_NAME}"
chmod 644 "${OUTPUT_DIR}/${ISO_NAME}"
ls -lh "${OUTPUT_DIR}/${ISO_NAME}"

echo "ISO built and copied to ${OUTPUT_DIR}/${ISO_NAME}"
