// архитектура набора команд
`ifndef ISA_DEFS_VH
`define ISA_DEFS_VH

`define OP_ADD   4'b0001
`define OP_SUB   4'b0010
`define OP_AND   4'b0011
`define OP_OR    4'b0100
`define OP_LOAD  4'b0101
`define OP_STORE 4'b0110
`define OP_LDI   4'b0111
`define OP_JUMP  4'b1000
`define OP_BEQ   4'b1001
`define OP_XOR   4'b1010
`define OP_NOT   4'b1011

`define ALU_ADD    4'b0001
`define ALU_SUB    4'b0010
`define ALU_AND    4'b0011
`define ALU_OR     4'b0100
`define ALU_XOR    4'b1010
`define ALU_NOT    4'b1011
`define ALU_PASS_A 4'b1100
`define ALU_PASS_B 4'b1101

`endif
