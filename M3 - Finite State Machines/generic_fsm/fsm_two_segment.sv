`timescale 1ns / 1ps

module fsm_two_segment
    (
        input logic clk, reset,
        input logic a, b,
        output logic y0, y1
    );
    
    // fsm state type
    typedef enum {s0, s1, s2} state_type;
    
    // signal declaration
    state_type state_reg, state_next;
    
    
    // [1] state register segment
    always_ff @(posedge clk, posedge reset)
        if(reset)
            state_reg <= s0;
        else
            state_reg <= state_next;
            
    // [2] combinational logic segment
    always_comb
    begin
        state_next = state_reg; // default next state: the same
        y0 = 1'b0;              // default y0 output = 0
        y1 = 1'b0;              // default y1 output = 0
        case(state_reg)
            s0: begin
                    y1 = 1'b1;
                    if(a)
                        if(b)
                        begin
                            y0 = 1'b1;
                            state_next = s2;
                        end
                        else
                            state_next = s1;
                    else
                        state_next = s0;
                end
            s1: 
                begin
                    y1 = 1'b1;
                    if(a)
                        state_next = s0;
                    else
                        state_next = s1;
                end
            s2: 
                state_next = s0;
            default: state_next = s0;          
        endcase
    end
        
    
endmodule

