// Файл: rtl/top_cpu.v
`include "isa_defs.vh"

module top_cpu (
    input  wire        clk,
    input  wire        rst_n,
    // Для наблюдения за работой (опционально)
    output wire [15:0] pc_out,
    output wire [15:0] instr_out,
    output wire [1:0]  state_out
);

    wire [15:0] pc_current, pc_next_val;
    wire        pc_load_sig;
    wire [15:0] instruction;
    wire [3:0]  opcode;
    wire [2:0]  dr, sr1, sr2;
    wire [2:0]  read_addr2_sel;
    wire [3:0]  alu_op;
    wire        reg_write, mem_write;
    wire        alu_src_b_sel;
    wire [15:0] read_data1, read_data2, alu_result, mem_read_data;
    wire [15:0] alu_b_input;
    wire [15:0] write_data_to_reg;
    wire [15:0] imm6_ext;
    wire [15:0] imm9_ext;
    wire        zero_flag_comb;
    reg         zero_flag_reg;

    assign opcode = instruction[15:12];
    assign dr  = instruction[11:9];
    assign sr1 = instruction[8:6];
    assign sr2 = instruction[5:3];
    assign read_addr2_sel = (opcode == `OP_STORE) ? dr : sr2;
    assign imm6_ext = {{10{instruction[5]}}, instruction[5:0]};
    assign imm9_ext = {{7{instruction[8]}}, instruction[8:0]};
    assign alu_b_input = (opcode == `OP_LDI) ? imm9_ext :
                         (alu_src_b_sel ? imm6_ext : read_data2);

    program_counter pc (
        .clk(clk), .rst_n(rst_n),
        .pc_load(pc_load_sig), .pc_next(pc_next_val),
        .pc_current(pc_current)
    );

    instruction_memory imem (
        .addr(pc_current), .instr(instruction)
    );

    register_file regfile (
        .clk(clk), .rst_n(rst_n),
        .reg_write(reg_write),
        .read_addr1(sr1), .read_addr2(read_addr2_sel),
        .write_addr(dr), .write_data(write_data_to_reg),
        .read_data1(read_data1), .read_data2(read_data2)
    );

    alu alu_unit (
        .a(read_data1), .b(alu_b_input), .alu_op(alu_op),
        .result(alu_result), .zero_flag(zero_flag_comb)
    );

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .addr(alu_result),          // Адрес для LOAD/STORE из АЛУ
        .write_data(read_data2),    // Данные для записи из второго регистра
        .read_data(mem_read_data)
    );

    control_unit ctrl (
        .clk(clk), .rst_n(rst_n),
        .instruction(instruction),
        .zero_flag(zero_flag_reg),
        .pc_load(pc_load_sig), .pc_next(pc_next_val),
        .reg_write(reg_write), .mem_write(mem_write),
        .alu_op(alu_op), .alu_src_b_sel(alu_src_b_sel),
        .state_debug(state_out)
    );

    assign write_data_to_reg = (opcode == `OP_LOAD) ? mem_read_data :
                               (opcode == `OP_LDI)  ? imm9_ext :
                               alu_result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            zero_flag_reg <= 1'b0;
        end else begin
            case (opcode)
                `OP_ADD,
                `OP_SUB,
                `OP_AND,
                `OP_OR,
                `OP_XOR,
                `OP_NOT: zero_flag_reg <= zero_flag_comb;
                `OP_LOAD,
                `OP_LDI: zero_flag_reg <= (write_data_to_reg == 16'd0);
                default: zero_flag_reg <= zero_flag_reg;
            endcase
        end
    end

    assign pc_out = pc_current;
    assign instr_out = instruction;

endmodule