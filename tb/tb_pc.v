`timescale 1ns / 1ps

module tb_pc;

    reg        clk, rst_n, pc_load;
    reg [15:0] pc_next;
    wire [15:0] pc_current;

    program_counter uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_load(pc_load),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    // Генерация тактов (период 10 нс)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_pc.vcd");
        $dumpvars(0, tb_pc);

        $display("=== PC test start ===");
        $display("Block purpose: program counter stores current instruction address.");
        $display("Signals: rst_n resets PC, pc_load loads jump target, pc_next is jump address.");

        clk = 0; rst_n = 0; pc_load = 0; pc_next = 0;
        #1;
        $display("[PC] reset active: rst_n=%b pc_load=%b pc_next=0x%04h pc_current=0x%04h",
                 rst_n, pc_load, pc_next, pc_current);
        if (pc_current !== 0) $error("Reset failed while reset is active");

        #9 rst_n = 1; // снимаем сброс
        #1;
        $display("[PC] reset released: rst_n=%b pc_current=0x%04h", rst_n, pc_current);
        if (pc_current !== 0) $error("PC changed too early after reset release");

        // Проверка инкремента
        @(posedge clk); #1;
        $display("[PC] increment step 1: pc_current=0x%04h (%0d)", pc_current, pc_current);
        if (pc_current !== 1) $error("Increment failed");
        @(posedge clk); #1;
        $display("[PC] increment step 2: pc_current=0x%04h (%0d)", pc_current, pc_current);
        if (pc_current !== 2) $error("Increment failed");

        // Проверка загрузки (JUMP)
        pc_load = 1; pc_next = 16'h0042;
        $display("[PC] request jump: pc_load=%b pc_next=0x%04h", pc_load, pc_next);
        @(posedge clk); #1; pc_load = 0;
        $display("[PC] after jump load: pc_current=0x%04h (%0d)", pc_current, pc_current);
        if (pc_current !== 16'h0042) $error("Jump load failed");

        // Проверка инкремента после загрузки
        @(posedge clk); #1;
        $display("[PC] increment after jump: pc_current=0x%04h (%0d)", pc_current, pc_current);
        if (pc_current !== 16'h0043) $error("Post-jump increment failed");

        $display("PC tests completed.");
        $finish;
    end

endmodule