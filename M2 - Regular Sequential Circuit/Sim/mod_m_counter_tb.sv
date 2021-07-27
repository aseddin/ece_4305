`timescale 1ns / 1ps

module mod_m_counter_tb();

// declarations
localparam M = 10; 
localparam T = 20;

// max_tick should be asserted every M x T

logic clk, reset, max_tick;
logic [$clog2(M) - 1:0] q;

// instantiate uut
mod_m_counter #(.M(M)) uut0(.*);

// test vectors

// clock (period = 20 ns)
always
begin
    clk = 1'b0;
    #(T / 2);
    clk = 1'b1;
    #(T / 2);
end

// initial reset
initial
begin
    reset = 1'b1;
    @(negedge clk)
    reset = 1'b0;
end
// monitor 
endmodule

