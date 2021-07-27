`timescale 1ns / 1ps

module univ_shift_reg_tb();

// declarations
localparam N = 8;
localparam T = 20; // clock period (20 ns)

logic clk, reset;
logic [1:0] ctrl;
logic [N - 1:0] d, q;


// instantiate unit under test (UUT)
univ_shift_reg #(.N(N)) uut0 (.*);

// test vector

// 20 ns clock running forever
always
begin
    clk = 1'b1;
    #(T / 2);
    clk = 1'b0;
    #(T / 2);
end

// reset for the first half cycle
initial
begin
    reset = 1'b1;
    #(T / 2);
    reset = 1'b0;
end

// increment d every 2 clock cycles
always
begin
    repeat(2) @(negedge clk)
    d = d + 1;
end

// stimuli
initial
begin
    // initial input valus (during the initial reset)
    d = 5;
    ctrl = 2'b11;
    
    #15;
    ctrl = 2'b00;
    
    wait(d == 10);
    ctrl = 2'b11;
    
    @(negedge clk);
    ctrl = 2'b01;
    
    #(5 *T); // wait for 100 ns
    $stop;
end
// monitor
endmodule

