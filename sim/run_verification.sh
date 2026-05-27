#!/usr/bin/env bash
# Запуск полной верификации (этап 3). Выполнять из корня проекта или из sim/.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

IVFLAGS="-g2012 -I rtl"
LOG="sim/simulation.log"
mkdir -p sim

echo "================================================================" | tee "$LOG"
echo "  CPU Verification Run" | tee -a "$LOG"
echo "  Date: $(date)" | tee -a "$LOG"
echo "  Project: $ROOT" | tee -a "$LOG"
echo "================================================================" | tee -a "$LOG"

PASS=0
FAIL=0

run_one() {
    local name="$1"
    local out="$2"
    shift 2
    echo "" | tee -a "$LOG"
    echo ">>> $name" | tee -a "$LOG"
    if iverilog $IVFLAGS -o "sim/$out" "$@" 2>&1 | tee -a "$LOG"; then
        if vvp "sim/$out" 2>&1 | tee -a "$LOG"; then
            PASS=$((PASS + 1))
            echo ">>> $name: OK" | tee -a "$LOG"
        else
            FAIL=$((FAIL + 1))
            echo ">>> $name: SIMULATION FAILED" | tee -a "$LOG"
        fi
    else
        FAIL=$((FAIL + 1))
        echo ">>> $name: COMPILE FAILED" | tee -a "$LOG"
    fi
}

run_one "tb_pc"           pc_tb           tb/tb_pc.v           rtl/pc.v
run_one "tb_reg_file"     reg_tb          tb/tb_reg_file.v     rtl/reg_file.v
run_one "tb_data_mem"     data_tb         tb/tb_data_mem.v     rtl/data_mem.v
run_one "tb_instr_mem"    instr_tb        tb/tb_instr_mem.v    rtl/instr_mem.v
run_one "tb_control_unit" ctrl_tb         tb/tb_control_unit.v rtl/control_unit.v
run_one "tb_alu"          alu_tb          tb/tb_alu.v          rtl/alu.v
run_one "tb_top_cpu"      simv            tb/tb_top_cpu.v      rtl/*.v

echo "" | tee -a "$LOG"
echo "================================================================" | tee -a "$LOG"
echo "  Summary: passed suites=$PASS failed=$FAIL" | tee -a "$LOG"
echo "  Log file: $LOG" | tee -a "$LOG"
echo "  Waveforms: sim/*.vcd" | tee -a "$LOG"
echo "================================================================" | tee -a "$LOG"

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi
