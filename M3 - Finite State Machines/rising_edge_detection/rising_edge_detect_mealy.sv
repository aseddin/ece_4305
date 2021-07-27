`timescale 1ns / 1ps

module rising_edge_detect_mealy   
    (
        input logic clk, reset,
        input logic level,
        output logic tick
    );
    
    // fsm state type
    typedef enum {zero, one} state_type;
    
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
    
    // [2] next-state logic & output logic (Mealy)
    always_comb
    begin
        tick = 1'b0;
        state_next = zero;
        case(state_reg)
            zero:
                if(level)
                begin
                    tick = 1'b1;
                    state_next = one;
                end
            one:
                if(level)
                begin
                    state_next = one;
                end
            default: state_next = zero;
        endcase
    end
endmodule

