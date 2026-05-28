#!/usr/bin/env bash
# Stage 5: FASM sum_series.asm -> tb/program.hex -> top_cpu simulation
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== Stage 5: sum_series (software -> tb/program.hex -> top_cpu) ==="

bash tools/build_program.sh software/sum_series.asm tb/program.hex

IVFLAGS="-g2012 -I rtl"
LOG="sim/stage5_simulation.log"
mkdir -p sim

echo "" | tee "$LOG"
echo ">>> tb/tb_top_cpu.v" | tee -a "$LOG"
iverilog $IVFLAGS -o sim/stage5_simv tb/tb_top_cpu.v rtl/*.v 2>&1 | tee -a "$LOG"
vvp sim/stage5_simv 2>&1 | tee -a "$LOG"

echo "" | tee -a "$LOG"
echo "Waveform: sim/tb_top_cpu.vcd" | tee -a "$LOG"
echo "Done." | tee -a "$LOG"
