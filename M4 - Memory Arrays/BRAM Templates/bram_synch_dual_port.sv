module bram_synch_dual_port
    #(parameter ADDR_WIDTH = 10, DATA_WIDTH = 8)
    (
        input logic clk,
        input logic we_a, we_b,
        input logic [ADDR_WIDTH - 1: 0] addr_a, addr_b,        
        input logic [DATA_WIDTH - 1: 0] din_a, din_b,       
        output logic [DATA_WIDTH - 1: 0] dout_a, dout_b
    );
    
    // signal declaration
    logic [DATA_WIDTH - 1: 0] memory [0: 2 ** ADDR_WIDTH - 1];
    
    // port a
    always_ff @(posedge clk)
    begin
        // write operation
        if (we_a)
            memory[addr_a] <= din_a;
        
        // read operation
        dout_a <= memory[addr_a];
    end
            
    // port b
    always_ff @(posedge clk)
    begin
        // write operation
        if (we_b)
            memory[addr_b] <= din_b;
        
        // read operation
        dout_b <= memory[addr_b];
    end
endmodule