#!/usr/bin/env bash
# Captures pub.dev screenshots from example/lib/screenshot_gallery.dart
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/screenshots"
EXAMPLE="$ROOT/example"
DEVICE="${1:-}"

mkdir -p "$OUT"
rm -f "$OUT"/*.png

if [[ -z "$DEVICE" ]]; then
  DEVICE="$(cd "$EXAMPLE" && flutter devices --machine | python3 -c 'import json,sys; ds=json.load(sys.stdin); print(next(d["id"] for d in ds if d.get("targetPlatform")=="ios" and "simulator" in d.get("name","").lower() or d.get("emulator")==True or "iPhone" in d.get("name","")))')"
fi

LOG="$(mktemp)"
trap 'rm -f "$LOG"; pkill -f screenshot_gallery.dart >/dev/null 2>&1 || true' EXIT

cd "$EXAMPLE"
flutter run -t lib/screenshot_gallery.dart -d "$DEVICE" 2>&1 | tee "$LOG" &

for scene in 01_tasks_inbox 02_compose_task 03_settings_gates 04_offline_banner 05_maintenance_gate 06_permission_gate; do
  for _ in $(seq 1 40); do
    if grep -q "SCREENSHOT_SCENE $scene" "$LOG"; then
      sleep 1.2
      xcrun simctl io booted screenshot "$OUT/${scene}.png"
      echo "captured $scene"
      break
    fi
    sleep 0.5
  done
done

echo "Done → $OUT"
ls -la "$OUT"
