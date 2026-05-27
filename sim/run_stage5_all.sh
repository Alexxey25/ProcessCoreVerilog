#!/usr/bin/env bash
# Assemble all stage-5 example programs (FASM)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== Stage 5: build all FASM examples ==="
for asm in software/sum_series.asm software/fibonacci.asm software/accumulate_mem.asm; do
    base=$(basename "$asm" .asm)
    bash tools/build_program.sh "$asm" "tb/program_${base}.hex"
    echo ""
done
echo "All programs built under tb/program_*.hex"
