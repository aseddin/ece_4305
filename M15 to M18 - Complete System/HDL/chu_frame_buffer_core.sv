module chu_frame_buffer_core 
   #(parameter CD = 12,   // color depth
               DW = 9     // frame buffer RAM data width
   )
   (
   input  logic clk, reset,
   // frame counter
   input  logic [10:0] x, y,
   // video slot interface
   input  logic cs,      
   input  logic write,  
   input  logic [19:0] addr,    
   input  logic [31:0] wr_data,
   // stream interface
   input  logic [CD-1:0] si_rgb,
   output logic [CD-1:0] so_rgb
);

   // delaration
   logic wr_en, wr_pix, wr_bypass;
   logic [CD-1:0] osd_rgb;
   logic [CD-1:0] frame_rgb;
   logic bypass_reg;
   
   // body
   // instantiate osd generator
   frame_src #(.CD(CD)) frame_src_unit (
      .clk(clk), .x(x), .y(y), .addr_pix(addr[18:0]), 
      .wr_data_pix(wr_data[DW-1:0]), .write_pix(wr_pix),
      .frame_rgb(frame_rgb));
   // register  
   always_ff @(posedge clk, posedge reset)
      if (reset) 
         bypass_reg <= 0;
      else 
         if (wr_bypass)
            bypass_reg <= wr_data[0];
   // decoding 
   assign wr_en = write & cs;
   assign wr_bypass = wr_en && addr==20'hfffff;
   assign wr_pix = wr_en && addr!=20'hfffff;
   // stream blending: mux
   assign so_rgb = bypass_reg ? si_rgb : frame_rgb;
endmodule
