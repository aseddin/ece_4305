module binary_counter
    #(parameter N = 8)
    (
        input logic clk, reset,
        output logic [N - 1:0] q,
        output logic max_tick
    );
    
    // start from the univ_shift_reg (just change the next state logic
    
    // signal declaration
    logic [N - 1:0] r_next, r_reg;
    
    // body
    // [1] Register segment
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end
    
    // [2] next-state logic segment
    assign r_next = r_reg + 1;
    
    // [3] output logic segment
    assign q = r_reg;    
    
    assign max_tick = (r_reg == 2**N-1) ? 1'b1: 1'b0;
    
endmodule

