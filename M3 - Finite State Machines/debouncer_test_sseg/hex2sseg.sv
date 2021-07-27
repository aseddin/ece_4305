`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2020 03:35:48 PM
// Design Name: 
// Module Name: hex2sseg
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


module hex2sseg(
    input logic [3:0] hex_in,
    input logic enable,
    output logic [6:0] sseg
    );
    
    always_comb
    begin
        if(enable)
            case(hex_in)
                4'h0:sseg = 7'b1000000;
                4'h1:sseg = 7'b1111001;
                4'h2:sseg = 7'b0100100;
                4'h3:sseg = 7'b0110000;
                4'h4:sseg = 7'b0011001;
                4'h5:sseg = 7'b0010010;
                4'h6:sseg = 7'b0000010;
                4'h7:sseg = 7'b1111000;
                4'h8:sseg = 7'b0000000;
                4'h9:sseg = 7'b0010000;
                4'ha:sseg = 7'b0001000;
                4'hb:sseg = 7'b0000011;
                4'hc:sseg = 7'b1000110;
                4'hd:sseg = 7'b0100001;
                4'he:sseg = 7'b0000110;
                4'hf:sseg = 7'b0001110;
                default: sseg = 7'b1111111;
            endcase
        else
            sseg = 7'b1111111;
    end
endmodule
