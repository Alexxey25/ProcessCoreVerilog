// Файл: rtl/pc.v
module program_counter (
    input  wire        clk,
    input  wire        rst_n,      // Асинхронный сброс (активный 0)
    input  wire        pc_load,    // Сигнал загрузки нового адреса (от FSM)
    input  wire [15:0] pc_next,    // Новый адрес перехода
    output reg  [15:0] pc_current  // Текущий адрес команды
);

    // Асинхронный сброс, синхронное обновление
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) // если rst_n = 0, сброс счетчика команд. rst = reset
            pc_current <= 16'h0000;   // Старт с адреса 0
        else if (pc_load)
            pc_current <= pc_next;
        else
            pc_current <= pc_current + 16'd1; // Линейное выполнение
    end

endmodule