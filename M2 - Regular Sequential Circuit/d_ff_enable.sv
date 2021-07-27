module d_ff_enable(
    input logic d, clk, reset, en,
    output logic q
    );
    
    always_ff @(posedge clk, posedge reset) // asynchronous reset
    begin
        if (reset)
            q <= 0;
        else if (en)
            q <= d;
    end
endmodule
