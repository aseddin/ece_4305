module bram_synch_one_port
    #(parameter ADDR_WIDTH = 10, DATA_WIDTH = 8)
    (
        input logic clk,
        input logic we,
        input logic [ADDR_WIDTH - 1: 0] addr_a,       
        input logic [DATA_WIDTH - 1: 0] din_a,       
        output logic [DATA_WIDTH - 1: 0] dout_a
    );
    
    // signal declaration
    logic [DATA_WIDTH - 1: 0] memory [0: 2 ** ADDR_WIDTH - 1];
    
    always_ff @(posedge clk)
    begin
        // write operation
        if (we)
            memory[addr_a] <= din_a;
        
        // read operation
        dout_a <= memory[addr_a];
    end
     
endmodule