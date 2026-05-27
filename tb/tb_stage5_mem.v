`timescale 1ns / 1ps
// Stage 5: partial sums 1..5 stored in MEM[1..5]

module tb_stage5_mem;

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
        $dumpfile("sim/tb_stage5_mem.vcd");
        $dumpvars(0, tb_stage5_mem);
        $dumpvars(0, uut.regfile.dbg_r1, uut.regfile.dbg_r3, uut.dmem.dbg_ram1);

        $display("=== Stage 5: accumulate_mem on top_cpu ===");

        clk = 0;
        rst_n = 0;
        errors = 0;
        cycle = 0;

        #10;
        rst_n = 1;

        repeat(100) begin
            @(posedge clk);
            #1;
            cycle = cycle + 1;
        end

        if (uut.regfile.registers[2] !== 16'd15) begin
            $error("R2 (total sum) expected 15, got %0d", uut.regfile.registers[2]);
            errors = errors + 1;
        end
        if (uut.dmem.ram[1] !== 16'd1) begin $error("MEM[1] expected 1, got %0d", uut.dmem.ram[1]); errors = errors + 1; end
        if (uut.dmem.ram[2] !== 16'd3) begin $error("MEM[2] expected 3, got %0d", uut.dmem.ram[2]); errors = errors + 1; end
        if (uut.dmem.ram[3] !== 16'd6) begin $error("MEM[3] expected 6, got %0d", uut.dmem.ram[3]); errors = errors + 1; end
        if (uut.dmem.ram[4] !== 16'd10) begin $error("MEM[4] expected 10, got %0d", uut.dmem.ram[4]); errors = errors + 1; end
        if (uut.dmem.ram[5] !== 16'd15) begin $error("MEM[5] expected 15, got %0d", uut.dmem.ram[5]); errors = errors + 1; end
        if (pc_out !== 16'd10) begin
            $error("PC expected halt at address 10, got %0d", pc_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("Stage 5 accumulate_mem PASSED (R2=15, MEM[1..5] ok).");
        else
            $display("Stage 5 accumulate_mem FAILED (%0d errors).", errors);

        $finish;
    end

endmodule
