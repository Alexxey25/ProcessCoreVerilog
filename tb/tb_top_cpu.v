`timescale 1ns / 1ps

module tb_top_cpu;

    reg        clk, rst_n;
    wire [15:0] pc_out, instr_out;
    wire [1:0]  state_out;
    integer errors;
    integer cycle;

    top_cpu uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .instr_out(instr_out),
        .state_out(state_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_top_cpu.vcd");
        $dumpvars(0, tb_top_cpu);

        $display("=== Top CPU test start ===");
        $display("Block purpose: integrates PC, instruction memory, control unit, register file, ALU and data memory.");
        $display("The CPU executes the program from tb/program.hex and we observe register and memory changes.");

        clk = 0;
        rst_n = 0;
        errors = 0;
        cycle = 0;

        #10 rst_n = 1;

        repeat(16) begin
            @(posedge clk);
            #1;
            cycle = cycle + 1;
            $display("[CPU] cycle=%0d pc=%0d instr=0x%04h state=%0d R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d R6=%0d R7=%0d MEM[1]=%0d",
                     cycle, pc_out, instr_out, state_out,
                     uut.regfile.registers[1], uut.regfile.registers[2], uut.regfile.registers[3],
                     uut.regfile.registers[4], uut.regfile.registers[5], uut.regfile.registers[6],
                     uut.regfile.registers[7], uut.dmem.ram[1]);
        end

        if (uut.regfile.registers[1] !== 16'd5) begin
            $error("R1 must contain 5, got %0d", uut.regfile.registers[1]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[2] !== 16'd3) begin
            $error("R2 must contain 3, got %0d", uut.regfile.registers[2]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[3] !== 16'd8) begin
            $error("R3 must contain 8, got %0d", uut.regfile.registers[3]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[4] !== 16'd8) begin
            $error("R4 must contain loaded value 8, got %0d", uut.regfile.registers[4]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[5] !== 16'd0) begin
            $error("R5 must contain 0 after SUB, got %0d", uut.regfile.registers[5]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[6] !== 16'd0) begin
            $error("R6 must remain 0 because BEQ skips LDI R6, got %0d", uut.regfile.registers[6]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[7] !== 16'd7) begin
            $error("R7 must contain OR result 7, got %0d", uut.regfile.registers[7]);
            errors = errors + 1;
        end
        if (uut.dmem.ram[1] !== 16'd8) begin
            $error("RAM[1] must contain stored value 8, got %0d", uut.dmem.ram[1]);
            errors = errors + 1;
        end
        if (pc_out !== 16'd9) begin
            $error("PC must stay at halt loop address 9, got %0d", pc_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("Top-level simulation PASSED.");
        else
            $display("Top-level simulation FAILED with %0d error(s).", errors);

        $finish;
    end

endmodule