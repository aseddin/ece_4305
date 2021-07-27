`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2020 02:51:09 PM
// Design Name: 
// Module Name: top
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


module top(
        input logic sw,
        input logic reset,
        input logic clk, // genrally the 100MHz
        output logic db,
        output logic [2:1] JA
    );
    
    delayed_debouncer deb(.*);
    
    assign JA[1] = sw;
    assign JA[2] = db;
endmodule
