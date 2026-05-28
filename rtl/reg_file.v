// Файл: rtl/reg_file.v
module register_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        reg_write,        // Разрешение записи (от FSM)
    input  wire [2:0]  read_addr1,       // Адрес первого операнда (SR1)
    input  wire [2:0]  read_addr2,       // Адрес второго операнда (SR2)
    input  wire [2:0]  write_addr,       // Адрес для записи (DR)
    input  wire [15:0] write_data,       // Данные для записи
    output wire [15:0] read_data1,       // Значение первого операнда
    output wire [15:0] read_data2        // Значение второго операнда
);

    // Память регистров (8 x 16 бит)
    reg [15:0] registers [0:7];
    
    // Запись (синхронная)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Сброс всех регистров (можно обнулить, но R0 всегда 0 аппаратно)
            integer i;
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 16'd0;
        end else if (reg_write && write_addr != 3'd0) begin
            // Запрещаем запись в R0
            registers[write_addr] <= write_data;
        end
    end
    
    // Чтение (асинхронное, комбинационное)
    assign read_data1 = (read_addr1 == 3'd0) ? 16'd0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 3'd0) ? 16'd0 : registers[read_addr2];

    // Пробные сигналы для VCD/GTKWave (массив registers в .vcd не всегда виден)
    wire [15:0] dbg_r1 = registers[1];
    wire [15:0] dbg_r2 = registers[2];
    wire [15:0] dbg_r3 = registers[3];
    wire [15:0] dbg_r7 = registers[7];

endmodule