module d_ff_reset(
    input logic d, clk, reset,
    output logic q
    );
    
    //always_ff @(posedge clk) // synchronous resert
    always_ff @(posedge clk, posedge reset) // asynchronous reset
    begin
        if (reset)
            q <= 0;
        else
            q <= d;
    end
endmodule
