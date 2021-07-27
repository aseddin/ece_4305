module chu_vga_bar_core (
   input  logic clk, reset,
   // frame counter
   input  logic [10:0] x, y,
   // video slot interface
   input  logic cs,      
   input  logic write,  
   input  logic [13:0] addr,    
   input  logic [31:0] wr_data,
   // stream interface
   input  logic [11:0] si_rgb,
   output logic [11:0] so_rgb
);

   // delaration
   logic wr_en;
   logic bypass_reg;
   logic [11:0] bar_rgb;
   
   // body
   // instantiate bar generator
   bar_src bar_src_unit 
      (.clk(clk), .x(x), .y(y), .bar_rgb(bar_rgb));
   // register  
   always_ff @(posedge clk, posedge reset)
      if (reset)
         bypass_reg <= 1;
      else if (wr_en)
         bypass_reg <= wr_data[0];
   // decoding 
   assign wr_en = write & cs;
   //  blending: bypass mux 
   assign so_rgb = bypass_reg ? si_rgb : bar_rgb;
endmodule