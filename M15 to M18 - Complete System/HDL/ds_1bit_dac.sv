module ds_1bit_dac 
   #(parameter W=16)       // width of input
   (
    input  logic clk, reset,
    input  logic [W-1:0] pcm_in, 
    output logic pdm_out
   );
   
   // declaration
   localparam BIAS = 2**(W-1);  //{1'b1, (W-2){1'b0}};
   logic [W:0] pcm_biased;
   logic [W:0] acc_next;
   logic [W:0] acc_reg;
   
   // body 
   // shift the range from [-2^(W-1)-1, 2^(W-1)-1] to [0, 2^W-1)] 
   assign pcm_biased = {pcm_in[W - 1], pcm_in} + BIAS;
   // signal treated as unsgined number in delta-sigma modulation
   assign acc_next = {1'b0, acc_reg[W-1:0]} + pcm_biased;
    // accumulation register
   always_ff @(posedge clk, posedge reset)
   if (reset)
      acc_reg <= 0;
   else
      acc_reg <= acc_next;
   // output
   assign pdm_out = acc_reg[W];
endmodule   

