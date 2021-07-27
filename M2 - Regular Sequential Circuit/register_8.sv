module register_8(
    input logic clk, reset, en,
    input logic [7:0] d,
    output logic [7:0] q
    );
    
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset)
            q <= 0;
        else if(en)
            q <= d;
    end
endmodule
