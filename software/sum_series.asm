; sum_series.asm — 1 + 2 + ... + 10 = 55  (результат в R2)
; Сборка: fasm software/sum_series.asm

format binary as 'rom.bin'
include 'cpu.inc'

    org 0

    LDI r1, 10          ; счётчик
    LDI r2, 0           ; сумма
    LDI r3, 1           ; текущее i

lp:
    ADD r2, r2, r3
    LDI r4, 1
    ADD r3, r3, r4
    SUB r1, r1, r4
    BEQ done
    JUMP lp

done:
    JUMP done
