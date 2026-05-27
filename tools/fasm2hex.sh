#!/usr/bin/env bash
# Convert FASM 16-bit little-endian .bin -> Verilog $readmemh .hex (one word per line)
set -euo pipefail
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.bin output.hex" >&2
    exit 1
fi
BIN=$1
HEX=$2
if [ ! -f "$BIN" ]; then
    echo "fasm2hex: file not found: $BIN" >&2
    exit 1
fi
mkdir -p "$(dirname "$HEX")"
hexdump -v -e '1/2 "%04X\n"' "$BIN" > "$HEX"
echo "fasm2hex: $(wc -l < "$HEX") word(s) -> $HEX"
