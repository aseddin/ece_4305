module synch_rom(
    input logic clk,
    input logic [2:0] addr,
    output logic [1:0] data
    );
    
    // signal declaration
    (*rom_style = "block" *)logic [1:0] rom [0:7];
    
    initial
        $readmemb("truth_table.mem", rom);
        
    always_ff @(posedge clk)
        data <= rom[addr];
endmodule