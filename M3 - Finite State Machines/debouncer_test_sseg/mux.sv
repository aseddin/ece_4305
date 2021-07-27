`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2020 03:35:48 PM
// Design Name: 
// Module Name: mux
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


module mux #(parameter BITS = 6)(
    input logic [BITS - 1:0] in0,
    input logic [BITS - 1:0] in1,
    input logic [BITS - 1:0] in2,
    input logic [BITS - 1:0] in3,
    input logic [BITS - 1:0] in4,
    input logic [BITS - 1:0] in5,
    input logic [BITS - 1:0] in6,
    input logic [BITS - 1:0] in7,
    input logic [2:0] sel,
    output logic [BITS - 1:0] mux_out
    );
    
    always_comb
    begin
        case(sel)
            0: mux_out = in0;
            1: mux_out = in1;
            2: mux_out = in2;
            3: mux_out = in3;
            4: mux_out = in4;
            5: mux_out = in5;
            6: mux_out = in6;
            7: mux_out = in7;
            default: mux_out = {BITS{1'bx}};
        endcase
    end
    
endmodule
