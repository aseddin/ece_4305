module bram_simple_synch_dual_port
    #(parameter ADDR_WIDTH = 10, DATA_WIDTH = 8)
    (
        input logic clk,
        input logic we,
        input logic [ADDR_WIDTH - 1: 0] addr_r, addr_w,        
        input logic [DATA_WIDTH - 1: 0] din,       
        output logic [DATA_WIDTH - 1: 0] dout
    );
    
    // signal declaration
    logic [DATA_WIDTH - 1: 0] memory [0: 2 ** ADDR_WIDTH - 1];
    
    always_ff @(posedge clk)
    begin
        // write operation
        if (we)
            memory[addr_w] <= din;
        
        // read operation
        dout <= memory[addr_r];
    end
     
endmodule