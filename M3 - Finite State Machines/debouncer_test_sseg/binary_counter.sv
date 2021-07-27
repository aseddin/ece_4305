`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2020 03:31:03 PM
// Design Name: 
// Module Name: binary_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module binary_counter
    #(parameter N = 8)
    (
        input logic clk, reset,
        input logic en,
        output logic [N - 1:0] q,
        output logic max_tick
    );
        
    // signal declaration
    logic [N - 1:0] r_next, r_reg;
    
    // body
    // [1] Register segment
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end
    
    // [2] next-state logic segment
    assign r_next = en? r_reg + 1: r_reg;
    
    // [3] output logic segment
    assign q = r_reg;    
    
    assign max_tick = (r_reg == 2**N-1) ? 1'b1: 1'b0;
    
endmodule


