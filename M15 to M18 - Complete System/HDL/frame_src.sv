module frame_src 
   #(
    parameter CD = 12, // color depth
              DW = 9   // video RAM data width
   )
   (
    input  logic clk,
    input  logic [10:0] x, y,   // x-and  y-coordinate    
    // write port 
    input  logic [18:0] addr_pix,
    input  logic [DW-1:0] wr_data_pix,
    input  logic write_pix,      
    // pixel output
    output logic [CD-1:0] frame_rgb
   );

   // declaration
   logic [DW-1:0] ram_rd_out_data;
   logic [CD-1:0] converted_color;
   logic [18:0] r_addr;
   logic [CD-1:0] frame_reg;
   
   //body 
   // instantiate video RAM
   vga_ram #(.DW(DW)) vram_unit (
      .clk(clk),
      // write port (to processor) 
      .we(write_pix), .addr_w(addr_pix[18:0]), 
      .data_w(wr_data_pix[DW-1:0]),
      // read port (to read pipe)
      .addr_r(r_addr), .data_r(ram_rd_out_data)
      );
   // instantiate palette circuit   
   frame_palette_9 pallete_unit (
      .color_in(ram_rd_out_data), .color_out(converted_color));
   // read address = 640*y + x = 512*y + 128*y + x
   assign r_addr = {1'b0, y[8:0],  9'b000000000} + 
                   {3'b000, y[8:0], 7'b0000000}  + x ;
   // 1 clock delay line
   always_ff @(posedge clk) 
      frame_reg <= converted_color;
   assign frame_rgb = frame_reg;   
endmodule

