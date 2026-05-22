#!/usr/bin/env bash
set -euo pipefail

ISO="${1:?ISO path required}"
TIMEOUT="${2:?TIMEOUT required}"

if [ ! -f "$ISO" ]; then
  echo "ERROR: ISO not found: $ISO" >&2
  exit 1
fi

echo "Smoke testing ISO: $ISO"
echo "Size: $(stat -c%s "$ISO") bytes"
echo "Timeout: ${TIMEOUT}s"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

KVM_OPTS=()
if [ -e /dev/kvm ]; then
  KVM_OPTS=(-accel kvm)
  echo "KVM acceleration available"
fi

echo "Booting ISO in QEMU..."

qemu-system-x86_64 \
  -m 2048 \
  -smp 2 \
  "${KVM_OPTS[@]}" \
  -cdrom "$ISO" \
  -nographic \
  -no-reboot \
  -serial mon:stdio \
  -device virtio-rng-pci \
  &>"${TMPDIR}/serial.log" &
QEMU_PID=$!

FOUND_LOGIN=false
END=$((SECONDS + TIMEOUT))
while [ $SECONDS -lt $END ]; do
  if grep -qi "login:" "${TMPDIR}/serial.log" 2>/dev/null; then
    FOUND_LOGIN=true
    break
  fi
  if ! kill -0 $QEMU_PID 2>/dev/null; then
    echo "QEMU process exited before login prompt"
    break
  fi
  sleep 2
done

kill $QEMU_PID 2>/dev/null || true
wait $QEMU_PID 2>/dev/null || true

cat "${TMPDIR}/serial.log"

if [ "$FOUND_LOGIN" = true ]; then
  echo ""
  echo "ISO smoke test PASSED"
else
  echo ""
  echo "ISO smoke test FAILED - no login prompt detected within ${TIMEOUT}s"
  echo "Last 50 lines of serial output:"
  tail -50 "${TMPDIR}/serial.log"
  exit 1
fi
