Программы для top_cpu (этап 5), сборка FASM
============================================

  cpu.inc              — макросы ISA (include во все .asm)
  sum_series.asm       — сумма 1+2+...+10, R2=55
  fibonacci.asm        — F(10)=55 в R3
  accumulate_mem.asm   — сумма 1..5 + STORE в MEM[1..5]

Сборка одной программы:
  fasm software/sum_series.asm
  bash tools/fasm2hex.sh software/sum_series.bin tb/program_stage5.hex

Или из корня проекта:
  bash tools/build_program.sh software/sum_series.asm tb/program_stage5.hex
  bash sim/run_stage5.sh
  bash sim/run_stage5_all.sh

Требуется FASM: https://flatassembler.net/
  WSL: sudo apt install fasm
