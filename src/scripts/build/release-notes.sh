#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
CHANGELOG_DIR="${PROJECT_DIR}/.changelog"
TAG="${1:?TAG required (e.g. v1.2.0)}"

VERSION="${TAG#v}"
CHANGELOG_FILE="${CHANGELOG_DIR}/${VERSION}.md"

if [ -f "${CHANGELOG_FILE}" ]; then
  cp "${CHANGELOG_FILE}" /dev/stdout
  exit 0
fi

CHANGELOG_FILE="${CHANGELOG_DIR}/${TAG}.md"
if [ -f "${CHANGELOG_FILE}" ]; then
  cp "${CHANGELOG_FILE}" /dev/stdout
  exit 0
fi

PREV_TAG=$(git tag --sort=-version:refname | head -2 | tail -1 2>/dev/null || true)

echo "Release ${TAG}"
echo ""

if [ -n "${PREV_TAG}" ]; then
  git log --oneline --no-decorate "${PREV_TAG}..${TAG}" 2>/dev/null || true
else
  git log --oneline --no-decorate "${TAG}" 2>/dev/null || true
fi
