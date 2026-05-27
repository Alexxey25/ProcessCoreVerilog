`timescale 1ns / 1ps

module tb_reg_file;

    reg        clk, rst_n, reg_write;
    reg [2:0]  read_addr1, read_addr2, write_addr;
    reg [15:0] write_data;
    wire [15:0] read_data1, read_data2;

    register_file uut (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(reg_write),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_reg_file.vcd");
        $dumpvars(0, tb_reg_file);

        $display("=== Register file test start ===");
        $display("Block purpose: stores 8 general-purpose registers and serves two read ports plus one write port.");

        clk = 0; rst_n = 0; reg_write = 0;
        read_addr1 = 0; read_addr2 = 0; write_addr = 0; write_data = 0;
        #10 rst_n = 1;
        $display("[REG] reset released. All registers must be zero.");

        // Проверка: R0 всегда читается как 0
        read_addr1 = 3'd0; #1;
        $display("[REG] read R0 -> 0x%04h", read_data1);
        if (read_data1 !== 0) $error("R0 read not zero");

        // Запись в R1 значения 0x1234
        @(posedge clk);
        reg_write = 1; write_addr = 3'd1; write_data = 16'h1234;
        $display("[REG] write request: reg_write=%b write_addr=R%0d write_data=0x%04h",
                 reg_write, write_addr, write_data);
        @(posedge clk);
        reg_write = 0;

        // Чтение R1 (асинхронно)
        read_addr1 = 3'd1; #1;
        $display("[REG] read R1 -> 0x%04h", read_data1);
        if (read_data1 !== 16'h1234) $error("Write/read to R1 failed");

        // Проверка одновременного чтения двух портов
        read_addr1 = 3'd1; read_addr2 = 3'd2;
        @(posedge clk); // запись в R2
        reg_write = 1; write_addr = 3'd2; write_data = 16'h5678;
        $display("[REG] write request: reg_write=%b write_addr=R%0d write_data=0x%04h",
                 reg_write, write_addr, write_data);
        @(posedge clk);
        reg_write = 0;
        #1; // даем комбинационному чтению обновиться
        $display("[REG] dual read: R1=0x%04h R2=0x%04h", read_data1, read_data2);
        if (read_data1 !== 16'h1234 || read_data2 !== 16'h5678) $error("Dual read failed");

        // Попытка записи в R0 (не должна сработать)
        @(posedge clk);
        reg_write = 1; write_addr = 3'd0; write_data = 16'hAAAA;
        $display("[REG] forbidden write request: write_addr=R0 write_data=0x%04h", write_data);
        @(posedge clk);
        reg_write = 0;
        read_addr1 = 3'd0; #1;
        $display("[REG] read R0 after forbidden write -> 0x%04h", read_data1);
        if (read_data1 !== 0) $error("Write to R0 should be ignored");

        $display("Register file tests completed.");
        $finish;
    end

endmodule