// Файл: rtl/instr_mem.v
module instruction_memory (
    input  wire [15:0] addr,
    output reg  [15:0] instr
);

    reg [15:0] rom [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            rom[i] = 16'h0000;
`ifdef PROGRAM_HEX_FILE
        $readmemh(`PROGRAM_HEX_FILE, rom);
`elsif QUARTUS_SYNTH
        // Quartus: cwd = quartus/top_cpu_quartus/
        $readmemh("../../tb/program.hex", rom);
`else
        // Icarus: cwd = корень verilogProject/
        $readmemh("tb/program.hex", rom);
`endif
    end

    always @(*) begin
        instr = rom[addr];
    end

endmodule