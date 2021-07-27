module univ_shift_reg
    #(parameter N = 8)
    (
        input logic clk, reset,
        input logic [1:0] ctrl,
        input logic [N - 1:0] d,
        output logic [N - 1:0] q
    );
    
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
    always_comb
    begin
        case(ctrl)
            2'b00: r_next = r_reg;
            2'b01: r_next = {r_reg[N - 2:0], d[0]}; // left shift
            2'b10: r_next = {d[N - 1], r_reg[N -1: 1]}; // right shift
            2'b11: r_next = d;
            default: r_next = r_reg;
        endcase
    end
    
    // [3] output logic segment
    assign q = r_reg;
endmodule

