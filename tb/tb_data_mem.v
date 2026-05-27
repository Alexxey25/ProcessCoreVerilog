`timescale 1ns / 1ps

module tb_data_mem;

    reg        clk, mem_write;
    reg [15:0] addr, write_data;
    wire [15:0] read_data;

    data_memory uut (
        .clk(clk),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_data_mem.vcd");
        $dumpvars(0, tb_data_mem);

        $display("=== Data memory test start ===");
        $display("Block purpose: stores data words for LOAD and STORE operations.");

        clk = 0; mem_write = 0; addr = 0; write_data = 0;
        #10;

        // Запись по адресу 10
        @(posedge clk);
        mem_write = 1; addr = 10; write_data = 16'hBEEF;
        $display("[DMEM] write request: mem_write=%b addr=%0d write_data=0x%04h",
                 mem_write, addr, write_data);
        @(posedge clk);
        mem_write = 0;
        $display("[DMEM] stored value at addr=%0d", addr);

        // Чтение (асинхронное)
        addr = 10; #1;
        $display("[DMEM] read: addr=%0d read_data=0x%04h", addr, read_data);
        if (read_data !== 16'hBEEF) $error("Read after write failed");

        // Проверка, что запись без разрешения не меняет память
        @(posedge clk);
        mem_write = 0; addr = 10; write_data = 16'hDEAD;
        $display("[DMEM] no-write check: mem_write=%b addr=%0d attempted_data=0x%04h",
                 mem_write, addr, write_data);
        #1;
        $display("[DMEM] read after blocked write: addr=%0d read_data=0x%04h", addr, read_data);
        if (read_data !== 16'hBEEF) $error("Data changed without mem_write");

        $display("Data memory tests completed.");
        $finish;
    end

endmodule