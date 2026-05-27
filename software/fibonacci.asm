; fibonacci.asm — F(10) = 55 в R3 (после цикла)
; Сборка: fasm software/fibonacci.asm

format binary as 'rom.bin'
include 'cpu.inc'

    org 0

    LDI r2, 0           ; F(0)
    LDI r3, 1           ; F(1)
    LDI r1, 9           ; итераций до F(10)=55 в R3

lp:
    ADD r5, r2, r3
    ADD r2, r3, r0      ; prev = curr  (R0 = 0)
    ADD r3, r5, r0      ; curr = next
    LDI r4, 1
    SUB r1, r1, r4
    BEQ done
    JUMP lp

done:
    JUMP done
