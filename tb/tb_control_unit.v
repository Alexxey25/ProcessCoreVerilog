`timescale 1ns / 1ps
`include "../rtl/isa_defs.vh"

module tb_control_unit;

    reg        clk, rst_n;
    reg [15:0] instruction;
    reg        zero_flag;
    wire       pc_load;
    wire [15:0] pc_next;
    wire       reg_write, mem_write;
    wire [3:0] alu_op;
    wire       alu_src_b_sel;
    wire [1:0] state_debug;

    control_unit uut (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction),
        .zero_flag(zero_flag),
        .pc_load(pc_load),
        .pc_next(pc_next),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .alu_src_b_sel(alu_src_b_sel),
        .state_debug(state_debug)
    );

    always #5 clk = ~clk;

    // Задача для подачи инструкции и наблюдения за проходом FSM
    task test_instruction;
        input [15:0] instr;
        input        expected_reg_write;
        input        expected_mem_write;
        input [3:0]  expected_alu_op;
        begin
            instruction = instr;
            zero_flag = 1'b0;
            $display("[CTRL] apply instruction=0x%04h", instr);
            // Ждем, пока FSM пройдет до WRITE_BACK/FETCH (достаточно 4 тактов)
            repeat(4) @(posedge clk);
            #1;
            $display("[CTRL] outputs: reg_write=%b mem_write=%b alu_op=0x%0h alu_src_b_sel=%b pc_load=%b pc_next=0x%04h state=%0d",
                     reg_write, mem_write, alu_op, alu_src_b_sel, pc_load, pc_next, state_debug);
            // Проверки
            if (reg_write !== expected_reg_write)
                $error("reg_write mismatch for instr %h", instr);
            if (mem_write !== expected_mem_write)
                $error("mem_write mismatch for instr %h", instr);
            if (alu_op !== expected_alu_op)
                $error("alu_op mismatch for instr %h", instr);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        $display("=== Control unit test start ===");
        $display("Block purpose: decodes opcode and generates control signals for the datapath.");
        $display("Signals of interest: reg_write, mem_write, alu_op, alu_src_b_sel, pc_load, pc_next.");

        clk = 0; rst_n = 0; instruction = 16'h0000; zero_flag = 0;
        #10 rst_n = 1;

        // Тест команды ADD R1,R2,R3
        $display("[CTRL] expected behavior for ADD: write result to register, ALU performs ADD.");
        test_instruction(16'b0001_001_010_011_000, 1'b1, 1'b0, `ALU_ADD);

        // Тест LOAD R4, [R5 + imm6]
        $display("[CTRL] expected behavior for LOAD: address via ALU add, then register write enabled.");
        test_instruction(16'b0101_100_101_000_001, 1'b1, 1'b0, `ALU_ADD);

        // Тест STORE R6, [R7 + imm6]
        $display("[CTRL] expected behavior for STORE: address via ALU add, then memory write enabled.");
        test_instruction(16'b0110_110_111_000_001, 1'b0, 1'b1, `ALU_ADD);

        // Тест JUMP immediate (опкод 4'b1000)
        instruction = 16'b1000_000_000_000_000; // адрес 0
        zero_flag = 0;
        @(posedge clk); // DECODE должен активировать pc_load
        #1;
        $display("[CTRL] JUMP outputs: pc_load=%b pc_next=0x%04h state=%0d",
                 pc_load, pc_next, state_debug);
        if (pc_load !== 1'b1) $error("JUMP should set pc_load");

        $display("Control unit tests completed.");
        $finish;
    end

endmodule