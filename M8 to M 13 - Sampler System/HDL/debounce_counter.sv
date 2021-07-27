module debounce_counter
   #(parameter N=20)  // 2^N * 10ns = 10ms tick
   (
    input  logic clk, reset,
    output logic ms10_tick
   );

   //signal declaration
   logic [N-1:0] r_reg;
   logic [N-1:0] r_next;

   // body
   // register
   always_ff @(posedge clk, posedge reset)
      if (reset)
         r_reg <= 0;  
      else
         r_reg <= r_next;

   // next-state logic
   assign r_next = r_reg + 1;
   // output logic
   assign q = r_reg;
   assign ms10_tick = r_reg==0;
endmodule