; accumulate_mem.asm — сумма 1..5 с записью в RAM[1..5]
; После выполнения: R2 = 15, MEM[1]=1, MEM[2]=3, MEM[3]=6, MEM[4]=10, MEM[5]=15
; Сборка: fasm software/accumulate_mem.asm

format binary as 'rom.bin'
include 'cpu.inc'

    org 0

    LDI r1, 5           ; counter
    LDI r2, 0           ; running sum
    LDI r3, 1           ; i (also index into MEM)

lp:
    ADD r2, r2, r3
    STORE r2, r3, 0     ; MEM[R3 + 0] = sum  (адрес = i)
    LDI r4, 1
    ADD r3, r3, r4
    SUB r1, r1, r4
    BEQ done
    JUMP lp

done:
    JUMP done
