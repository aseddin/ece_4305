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
        output logic [6:0] sseg,
        output logic [7:0] an
    );
    
    // delayed debouncer
    logic db; // debounced switch signal
    delayed_debouncer deb(.*);
    
    // edge detectors
    logic sw_tick, db_tick;
    
    rising_edge_detect_mealy sw_edge(
        .level(sw),
        .tick(sw_tick),
        .*
    );
    
    rising_edge_detect_mealy db_edge(
        .level(db),
        .tick(db_tick),
        .*
    );
    
    // binary counters
    logic [7:0] sw_count, db_count;
    
    binary_counter sw_counter(
        .q(sw_count),
        .en(sw_tick),
        .max_tick(),
        .*
    ); 
    
    binary_counter db_counter(
        .q(db_count),
        .en(db_tick),
        .max_tick(),
        .*
    ); 
    
    time_mux_disp disp (
        .in0({1'b1 ,sw_count[3:0], 1'b1}),
        .in1({1'b1 ,sw_count[7:4], 1'b1}),
        .in2(),
        .in3(),
        .in4({1'b1 ,db_count[3:0], 1'b1}),
        .in5({1'b1 ,db_count[7:4], 1'b1}),
        .in6(),
        .in7(),
        .dp(),
        .*
    );
endmodule
