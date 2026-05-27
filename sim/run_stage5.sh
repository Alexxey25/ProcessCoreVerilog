#!/usr/bin/env bash
# Stage 5: FASM -> hex -> simulation on top_cpu
# Usage: bash sim/run_stage5.sh [software/PROGRAM.asm]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ASM="${1:-software/sum_series.asm}"
BASE=$(basename "$ASM" .asm)

case "$BASE" in
    sum_series)      TB="tb/tb_stage5_sum.v";  VCD="sim/tb_stage5_sum.vcd" ;;
    fibonacci)       TB="tb/tb_stage5_fib.v";  VCD="sim/tb_stage5_fib.vcd" ;;
    accumulate_mem)  TB="tb/tb_stage5_mem.v";  VCD="sim/tb_stage5_mem.vcd" ;;
    *)
        echo "WARNING: no dedicated testbench for '$BASE', using tb_stage5_sum.v" >&2
        TB="tb/tb_stage5_sum.v"
        VCD="sim/tb_stage5_${BASE}.vcd"
        ;;
esac

echo "=== Stage 5: Software / HW integration (FASM) ==="
echo "Program: $ASM"
echo "Testbench: $TB"

bash tools/build_program.sh "$ASM" tb/program_stage5.hex

IVFLAGS="-g2012 -I rtl -DPROGRAM_HEX_FILE=\"tb/program_stage5.hex\""
LOG="sim/stage5_simulation.log"
mkdir -p sim

echo "" | tee "$LOG"
echo ">>> $TB" | tee -a "$LOG"
iverilog $IVFLAGS -o sim/stage5_simv "$TB" rtl/*.v 2>&1 | tee -a "$LOG"
vvp sim/stage5_simv 2>&1 | tee -a "$LOG"

echo "" | tee -a "$LOG"
echo "Waveform: $VCD" | tee -a "$LOG"
echo "Done." | tee -a "$LOG"
