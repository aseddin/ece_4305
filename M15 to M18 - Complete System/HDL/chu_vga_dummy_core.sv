// "place holder" in a cascading chain 
module chu_vga_dummy_core (
   input logic clk, reset,
   // video slot interface
   input  logic cs,      
   input  logic write,  
   input  logic [13:0] addr,    
   input  logic [31:0] wr_data,
   // stream interface
   input  logic [11:0] si_rgb,
   output logic [11:0] so_rgb
  );

   assign so_rgb = si_rgb;
endmodule