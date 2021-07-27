`timescale 1ns / 1ps


module rising_edge_detect_moore
    (
        input logic clk, reset,
        input logic level,
        output logic tick
    );
    
    // fsm state type
    typedef enum {zero, edg, one} state_type;
    
    // signal declaration
    state_type state_reg, state_next;
    
    // [1] State register
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset)
            state_reg <= zero;
        else
            state_reg <= state_next;
    end
    
    // [2] next-state logic
    always_comb
    begin
        case(state_reg)
            zero:
                if(level)
                    state_next = edg;
                else
                    state_next = zero;
            edg:
                if(level)
                    state_next = one;
                else
                    state_next = zero;
            one:
                if(level)
                    state_next = one;
                else
                    state_next = zero;
            default: state_next <= zero;
        endcase
    end
    
    // [3] Moore output
    assign tick = (state_reg == edg);
endmodule

