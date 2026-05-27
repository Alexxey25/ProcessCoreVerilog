; cpu.inc — макросы FASM для ISA top_cpu (16-битные слова)
; Адреса меток: байтовый $  ->  номер слова = label shr 1

r0 = 0
r1 = 1
r2 = 2
r3 = 3
r4 = 4
r5 = 5
r6 = 6
r7 = 7

OP_ADD   = 0x1
OP_SUB   = 0x2
OP_AND   = 0x3
OP_OR    = 0x4
OP_LOAD  = 0x5
OP_STORE = 0x6
OP_LDI   = 0x7
OP_JUMP  = 0x8
OP_BEQ   = 0x9
OP_XOR   = 0xA
OP_NOT   = 0xB

macro ENCODE_R op, dr, sr1, sr2 {
    dw (op shl 12) or (dr shl 9) or (sr1 shl 6) or (sr2 shl 3)
}

macro ADD dr, sr1, sr2 { ENCODE_R OP_ADD, dr, sr1, sr2 }
macro SUB dr, sr1, sr2 { ENCODE_R OP_SUB, dr, sr1, sr2 }
macro AND dr, sr1, sr2 { ENCODE_R OP_AND, dr, sr1, sr2 }
macro OR  dr, sr1, sr2 { ENCODE_R OP_OR,  dr, sr1, sr2 }
macro XOR dr, sr1, sr2 { ENCODE_R OP_XOR, dr, sr1, sr2 }
macro NOT dr, sr1      { ENCODE_R OP_NOT, dr, sr1, 0 }

macro LDI dr, imm {
    dw (OP_LDI shl 12) or (dr shl 9) or (imm and 0x1FF)
}

macro LOAD dr, sr1, off {
    dw (OP_LOAD shl 12) or (dr shl 9) or (sr1 shl 6) or (off and 0x3F)
}

macro STORE dr, sr1, off {
    dw (OP_STORE shl 12) or (dr shl 9) or (sr1 shl 6) or (off and 0x3F)
}

macro JUMP target {
    dw (OP_JUMP shl 12) or ((target shr 1) and 0xFFF)
}

macro BEQ target {
    dw (OP_BEQ shl 12) or ((target shr 1) and 0xFFF)
}

macro NOP {
    dw 0
}
