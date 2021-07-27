module rom_with_file(
    input logic [2:0] addr,
    output logic [1:0] data
    );
    
    // signal declaration
    logic [1:0] rom [0:7];
    
    initial
        $readmemh("hex_truth_table.mem", rom);
        
    assign data = rom[addr];
endmodule