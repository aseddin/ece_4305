module chu_rgb2gray_core (
   input  logic clk, reset,
   // video slot interface
   input  logic cs,      
   input  logic write,  
   input  logic [13:0] addr,    
   input  logic [31:0] wr_data,
   // stream interface
   input  logic [11:0] si_rgb,
   output logic [11:0] so_rgb
);
  
   // signal delaration
   logic wr_en;
   logic bypass_reg;
   logic [11:0] gray_rgb;
   
   // body 
   // instantiate rgb-to-garyscale conversion circuit
   rgb2gray rgb2gray_unit 
      (.color_rgb(si_rgb), .gray_rgb(gray_rgb));
   // register  
   always_ff @(posedge clk, posedge reset)
      if (reset)
         bypass_reg <= 1;
      else if (wr_en)
         bypass_reg <= wr_data[0];
   // decoding 
   assign wr_en = write & cs;
   // blending: bypass mux
   assign so_rgb = bypass_reg ? si_rgb : gray_rgb;
endmodule
