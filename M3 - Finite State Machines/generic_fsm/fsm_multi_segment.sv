`timescale 1ns / 1ps


module fsm_multi_segment
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
            
    // [2] next-state logic segment
    always_comb
    begin
        case(state_reg)
            s0: 
                if(a)              
                    if(b)
                        state_next = s2;
                    else
                        state_next = s1;
                else
                    state_next = s0;
                
            s1: 
                if(a)
                    state_next = s0;
                else
                    state_next = s1;
            s2: 
                state_next = s0;
            default: state_next = s0;          
        endcase
    end
        
    // [3] Moore output logic segment
    assign y1 = (state_reg == s0) || (state_reg == s1);
    
    // [4] Mealy output logic segment
    assign y0 = (state_reg == s0) &a & b;
    
endmodule

