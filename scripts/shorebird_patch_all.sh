#!/usr/bin/env bash
# Patches every active Shorebird Android release with the current Dart code.
#
# Usage:
#   ./scripts/shorebird_patch_all.sh                 # patch all listed releases
#   ./scripts/shorebird_patch_all.sh 2.7.7+66 ...    # patch only given versions
#
# Full output goes to logs/shorebird_patch_<timestamp>.log
# Watch live with:  tail -f logs/shorebird_patch_*.log

set -u
export PATH="$HOME/.shorebird/bin:$PATH"

cd "$(dirname "$0")/.." || exit 1

RELEASES=(2.7.7+66 2.7.0+63 2.6.6+63 2.6.5+62 2.6.4+61 2.5.3+60 2.5.2+59 2.5.1+58 2.5.0+57)
if [ "$#" -gt 0 ]; then
  RELEASES=("$@")
fi

mkdir -p logs
LOG_FILE="logs/shorebird_patch_$(date +%Y%m%d_%H%M%S).log"

declare -A RESULTS

echo "Patching ${#RELEASES[@]} release(s). Full log: $LOG_FILE" | tee "$LOG_FILE"

for version in "${RELEASES[@]}"; do
  echo "" | tee -a "$LOG_FILE"
  echo "════════════════════════════════════════════════" | tee -a "$LOG_FILE"
  echo "▶ Patching $version  ($(date +%H:%M:%S))" | tee -a "$LOG_FILE"
  echo "════════════════════════════════════════════════" | tee -a "$LOG_FILE"

  if shorebird patch android --release-version="$version" --no-confirm >>"$LOG_FILE" 2>&1; then
    RESULTS[$version]="OK"
    echo "✔ $version patched successfully" | tee -a "$LOG_FILE"
  else
    RESULTS[$version]="FAILED"
    echo "✖ $version FAILED — last lines of output:" | tee -a "$LOG_FILE"
    tail -15 "$LOG_FILE" | sed 's/^/    /'
  fi
done

echo "" | tee -a "$LOG_FILE"
echo "═══════════════ SUMMARY ═══════════════" | tee -a "$LOG_FILE"
for version in "${RELEASES[@]}"; do
  printf '  %-12s %s\n' "$version" "${RESULTS[$version]}" | tee -a "$LOG_FILE"
done
echo "═══════════════════════════════════════" | tee -a "$LOG_FILE"
echo "Full log: $LOG_FILE"
