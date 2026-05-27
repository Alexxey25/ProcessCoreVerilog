// Файл: rtl/control_unit.v
`include "isa_defs.vh"

module control_unit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] instruction,  // Текущая команда из instr_mem
    input  wire        zero_flag,    // Флаг из АЛУ
    // Управляющие сигналы для Data Path
    output reg         pc_load,
    output reg  [15:0] pc_next,
    output reg         reg_write,
    output reg         mem_write,
    output reg  [3:0]  alu_op,
    output reg         alu_src_b_sel, // Выбор между регистром и Immediate
    output reg  [1:0]  state_debug
);
    localparam FETCH_STATE   = 2'b00;
    localparam EXECUTE_STATE = 2'b01;

    wire [3:0] opcode = instruction[15:12];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_debug <= FETCH_STATE;
        else if (state_debug == FETCH_STATE)
            state_debug <= EXECUTE_STATE;
        else
            state_debug <= FETCH_STATE;
    end

    always @(*) begin
        pc_load = 1'b0;
        pc_next = 16'd0;
        reg_write = 1'b0;
        mem_write = 1'b0;
        alu_op = `ALU_ADD;
        alu_src_b_sel = 1'b0;

        case (opcode)
            `OP_ADD: begin
                reg_write = 1'b1;
                alu_op = `ALU_ADD;
            end
            `OP_SUB: begin
                reg_write = 1'b1;
                alu_op = `ALU_SUB;
            end
            `OP_AND: begin
                reg_write = 1'b1;
                alu_op = `ALU_AND;
            end
            `OP_OR: begin
                reg_write = 1'b1;
                alu_op = `ALU_OR;
            end
            `OP_XOR: begin
                reg_write = 1'b1;
                alu_op = `ALU_XOR;
            end
            `OP_NOT: begin
                reg_write = 1'b1;
                alu_op = `ALU_NOT;
            end
            `OP_LOAD: begin
                reg_write = 1'b1;
                alu_op = `ALU_ADD;
                alu_src_b_sel = 1'b1;
            end
            `OP_STORE: begin
                mem_write = 1'b1;
                alu_op = `ALU_ADD;
                alu_src_b_sel = 1'b1;
            end
            `OP_LDI: begin
                reg_write = 1'b1;
                alu_op = `ALU_PASS_B;
            end
            `OP_JUMP: begin
                pc_load = 1'b1;
                pc_next = {4'd0, instruction[11:0]};
            end
            `OP_BEQ: begin
                if (zero_flag) begin
                    pc_load = 1'b1;
                    pc_next = {4'd0, instruction[11:0]};
                end
            end
            default: begin
                // NOP
            end
        endcase
    end

endmodule