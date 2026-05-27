`timescale 1ns / 1ps
// Stage 5: run assembled program on top_cpu (sum 1..10 = 55)

module tb_stage5_sum;

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
        $dumpfile("sim/tb_stage5_sum.vcd");
        $dumpvars(0, tb_stage5_sum);
        $dumpvars(0, uut.regfile.dbg_r1, uut.regfile.dbg_r3, uut.regfile.dbg_r7);
        $dumpvars(0, uut.dmem.dbg_ram1);

        $display("=== Stage 5: sum 1+2+...+10 on top_cpu ===");
        $display("Program: tb/program_stage5.hex");

        clk = 0;
        rst_n = 0;
        errors = 0;
        cycle = 0;

        #10;
        rst_n = 1;

        repeat(80) begin
            @(posedge clk);
            #1;
            cycle = cycle + 1;
            if (cycle <= 40 || cycle % 4 == 0)
                $display("[CPU] c=%0d pc=%0d instr=0x%04h R1=%0d R2=%0d R3=%0d",
                         cycle, pc_out, instr_out,
                         uut.regfile.registers[1],
                         uut.regfile.registers[2],
                         uut.regfile.registers[3]);
        end

        if (uut.regfile.registers[2] !== 16'd55) begin
            $error("R2 (sum) expected 55, got %0d", uut.regfile.registers[2]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[1] !== 16'd0) begin
            $error("R1 (counter) expected 0, got %0d", uut.regfile.registers[1]);
            errors = errors + 1;
        end
        if (uut.regfile.registers[3] !== 16'd11) begin
            $error("R3 (i after loop) expected 11, got %0d", uut.regfile.registers[3]);
            errors = errors + 1;
        end
        if (pc_out !== 16'd9) begin
            $error("PC expected halt at address 9, got %0d", pc_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("Stage 5 sum_series PASSED (R2=55).");
        else
            $display("Stage 5 sum_series FAILED (%0d errors).", errors);

        $finish;
    end

endmodule
