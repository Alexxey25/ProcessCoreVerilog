`timescale 1ns / 1ps

module tb_instr_mem;

    reg [15:0] addr;
    wire [15:0] instr;

    instruction_memory uut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $dumpfile("sim/tb_instr_mem.vcd");
        $dumpvars(0, tb_instr_mem);

        $display("=== Instruction memory test start ===");
        $display("Block purpose: stores program instructions loaded from tb/program.hex.");
        $display("program.hex format: one 16-bit instruction per line in hexadecimal.");

        addr = 0; #10;
        $display("[IMEM] addr=%0d instr=0x%04h -> LDI R1, 5", addr, instr);
        if (instr !== 16'h7205) $error("First instruction mismatch");
        addr = 1; #10;
        $display("[IMEM] addr=%0d instr=0x%04h -> LDI R2, 3", addr, instr);
        if (instr !== 16'h7403) $error("Second instruction mismatch");
        addr = 2; #10;
        $display("[IMEM] addr=%0d instr=0x%04h -> ADD R3, R1, R2", addr, instr);
        if (instr !== 16'h1650) $error("Third instruction mismatch");

        $display("Instruction memory tests completed.");
        $finish;
    end

endmodule