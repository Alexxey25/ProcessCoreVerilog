`timescale 1ns / 1ps
`include "../rtl/isa_defs.vh"

module tb_alu;

    reg  [15:0] a, b;
    reg  [3:0]  alu_op;
    wire [15:0] result;
    wire        zero_flag;
    integer     errors;

    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero_flag(zero_flag)
    );

    task check_alu;
        input [15:0] exp_result;
        input        exp_zero;
        input [255:0] name;
        begin
            #1;
            if (result !== exp_result) begin
                $error("%s: result=%0d expected=%0d", name, result, exp_result);
                errors = errors + 1;
            end
            if (zero_flag !== exp_zero) begin
                $error("%s: zero_flag=%b expected=%b", name, zero_flag, exp_zero);
                errors = errors + 1;
            end
            $display("[ALU] %s: a=%0d b=%0d result=%0d zero=%b OK",
                     name, a, b, result, zero_flag);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_alu.vcd");
        $dumpvars(0, tb_alu);

        errors = 0;
        $display("=== ALU test start ===");

        a = 16'd5; b = 16'd3; alu_op = `ALU_ADD;
        check_alu(16'd8, 1'b0, "ADD 5+3");

        a = 16'd8; b = 16'd3; alu_op = `ALU_SUB;
        check_alu(16'd5, 1'b0, "SUB 8-3");

        a = 16'd5; b = 16'd5; alu_op = `ALU_SUB;
        check_alu(16'd0, 1'b1, "SUB 5-5");

        a = 16'h00F0; b = 16'h0F0F; alu_op = `ALU_AND;
        check_alu(16'h0000, 1'b1, "AND");

        a = 16'h00F0; b = 16'h0F0F; alu_op = `ALU_OR;
        check_alu(16'h0FFF, 1'b0, "OR");

        a = 16'h00FF; b = 16'h0F0F; alu_op = `ALU_XOR;
        check_alu(16'h0FF0, 1'b0, "XOR");

        a = 16'h00FF; b = 16'd0; alu_op = `ALU_NOT;
        check_alu(16'hFF00, 1'b0, "NOT");

        if (errors == 0)
            $display("ALU tests completed.");
        else
            $display("ALU tests FAILED with %0d error(s).", errors);

        $finish;
    end

endmodule
