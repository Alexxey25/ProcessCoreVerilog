// Файл: rtl/alu.v
`include "isa_defs.vh"

module alu (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [3:0]  alu_op,      // Операция (opcode или производный от него)
    output reg  [15:0] result,
    output wire        zero_flag
);

    always @(*) begin
        case (alu_op)
            `ALU_ADD:    result = a + b;
            `ALU_SUB:    result = a - b;
            `ALU_AND:    result = a & b;
            `ALU_OR:     result = a | b;
            `ALU_XOR:    result = a ^ b;
            `ALU_NOT:    result = ~a;
            `ALU_PASS_A: result = a;
            `ALU_PASS_B: result = b;
            default:     result = 16'd0;
        endcase
    end

    assign zero_flag = (result == 16'd0);

endmodule