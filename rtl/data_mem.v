// Файл: rtl/data_mem.v
module data_memory (
    input  wire        clk,
    input  wire        mem_write,     // Сигнал записи от FSM
    input  wire [15:0] addr,          // Адрес (обычно из ALU result)
    input  wire [15:0] write_data,    // Данные из регистрового файла
    output wire [15:0] read_data      // Данные для загрузки в регистр
);

    reg [15:0] ram [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            ram[i] = 16'h0000;
    end

    // Синхронная запись
    always @(posedge clk) begin
        if (mem_write) // пишем в память
            ram[addr] <= write_data;
    end
    
    // Асинхронное чтение (или синхронное – зависит от реализации)
    assign read_data = ram[addr];

    // Пробный сигнал для VCD/GTKWave (ячейка RAM[1] из тестовой программы)
    wire [15:0] dbg_ram1 = ram[1];

endmodule