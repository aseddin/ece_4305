module ram_3port
    #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)
    (
        input logic clk,
        input logic we,
        input logic [ADDR_WIDTH - 1: 0] r_addr0, r_addr1, // reading address
        input logic [ADDR_WIDTH - 1: 0] w_addr, // writing address
        input logic [DATA_WIDTH - 1: 0] w_data,
        output logic [DATA_WIDTH - 1: 0] r_data0, r_data1
    );
    
        // signal declaration
    logic [DATA_WIDTH - 1: 0] memory [0: 2 ** ADDR_WIDTH - 1];
    
    // write operation
    always_ff @(posedge clk)
    begin
        if (we)
            memory[w_addr] <= w_data;            
    end
    // read operation
    assign r_data0 = memory[r_addr0];
    assign r_data1 = memory[r_addr1];

endmodule