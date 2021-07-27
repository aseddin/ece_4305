// baud rate generater (divisor) 
// divided by (dvsr+1)
// Listing 12.1
module baud_gen
   (
    input  logic clk, reset,
    input  logic [10:0] dvsr,
    output logic tick
   );

   // declaration
   logic [10:0] r_reg;
   logic [10:0] r_next;

   // body
   // register
   always_ff @(posedge clk, posedge reset)
      if (reset)
         r_reg <= 0;
      else
         r_reg <= r_next;

   // next-state logic
   assign r_next = (r_reg==dvsr) ? 0 : r_reg + 1;
   // output logic
   assign tick = (r_reg==1);
endmodule