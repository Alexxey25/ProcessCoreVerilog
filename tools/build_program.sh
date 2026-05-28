#!/usr/bin/env bash
# Assemble one FASM program -> tb/*.hex
# Usage: tools/build_program.sh software/sum_series.asm [tb/program.hex]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ASM=${1:?usage: build_program.sh software/foo.asm [output.hex]}
OUT_HEX=${2:-}

BASE=$(basename "$ASM" .asm)
DIR=$(dirname "$ASM")
SRC_DIR=$(cd "$DIR" && pwd)
ROM_BIN="$SRC_DIR/rom.bin"
BIN="$SRC_DIR/${BASE}.bin"
LST="$SRC_DIR/${BASE}.lst"

if [ -z "$OUT_HEX" ]; then
    OUT_HEX="tb/program_${BASE}.hex"
fi

mkdir -p "$(dirname "$OUT_HEX")"

if ! command -v fasm >/dev/null 2>&1; then
    echo "ERROR: FASM not found. Install:" >&2
    echo "  WSL: sudo apt install fasm   (or https://flatassembler.net/)" >&2
    echo "  Windows: add fasm.exe to PATH" >&2
    exit 1
fi

echo ">>> FASM $ASM"
(
    cd "$SRC_DIR"
    rm -f rom.bin "${BASE}.bin"
    fasm "${BASE}.asm"
    if [ -f "${BASE}.rom.bin" ]; then
        mv -f "${BASE}.rom.bin" "${BASE}.bin"
    elif [ -f rom.bin ]; then
        mv -f rom.bin "${BASE}.bin"
    elif [ -f "${BASE}.${BASE}.bin" ]; then
        mv -f "${BASE}.${BASE}.bin" "${BASE}.bin"
    fi
)

if [ ! -f "$BIN" ]; then
    echo "ERROR: FASM did not produce $BIN" >&2
    exit 1
fi

bash tools/fasm2hex.sh "$BIN" "$OUT_HEX"
echo ">>> ROM hex: $OUT_HEX"
if [ -f "$LST" ]; then
    echo ">>> Listing: $LST"
fi
