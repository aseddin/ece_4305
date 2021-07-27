`timescale 1ns / 1ps

module rising_edge_detect_tb(

    );
    
    // declarations
    localparam T = 10; // clock period (10 ns)
    
    logic clk, reset, level;
    logic tick_mealy, tick_moore;
    
    // insantiate uuts
    
    // Mealy
    rising_edge_detect_mealy mealy_uut
                            (   .tick(tick_mealy),
                                .*);
    
    // Moore
    rising_edge_detect_moore moore_uut
                            (   .tick(tick_moore),
                                .*);
    
    // test vector
    //10 ns clock running forever
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
    
    // stimuli (just the tick
    initial
    begin        
        repeat(3) @(negedge clk);
        #2;
        level = 1'b1;
        
        @(negedge clk);
        level = 1'b0;
        
        repeat(4) @(negedge clk);
        level = 1'b1;
        
        @(posedge clk);
        level = 1'b0;
        
        repeat(3) @(posedge clk);
        
        $finish;
    end
    
endmodule

