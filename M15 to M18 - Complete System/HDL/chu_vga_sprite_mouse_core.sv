module chu_vga_sprite_mouse_core 
   #(parameter CD = 12,   // color depth
               ADDR_WIDTH = 10,
               KEY_COLOR = 0
   )
   (
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
   logic wr_en, wr_ram, wr_reg, wr_bypass, wr_x0, wr_y0;
   logic [CD-1:0] mouse_rgb, chrom_rgb;
   logic [10:0] x0_reg, y0_reg;
   logic bypass_reg;

   // body
   // instantiate sprite generator
   mouse_src #(.CD(12), .KEY_COLOR(0)) mouse_src_unit (
       .clk(clk), 
       .x(x), .y(y), 
       .x0(x0_reg), .y0(y0_reg),
       .we(wr_ram), .addr_w(addr[ADDR_WIDTH-1:0]),
       .pixel_in(wr_data[CD-1:0]), 
       .mouse_rgb(mouse_rgb));
       
   // register  
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         x0_reg <= 0;
         y0_reg <= 0;
         bypass_reg <= 0;
      end   
      else begin
         if (wr_x0)
            x0_reg <= wr_data[10:0];
         if (wr_y0)
            y0_reg <= wr_data[10:0];
         if (wr_bypass)
            bypass_reg <= wr_data[0];
      end      
   // decoding 
   assign wr_en = write & cs;
   assign wr_ram = ~addr[13] && wr_en;
   assign wr_reg = addr[13] && wr_en;
   assign wr_bypass = wr_reg && (addr[1:0]==2'b00);
   assign wr_x0 = wr_reg && (addr[1:0]==2'b01);
   assign wr_y0 = wr_reg && (addr[1:0]==2'b10);
   // chrome-key blending and multiplexing
   assign chrom_rgb = (mouse_rgb != KEY_COLOR) ? mouse_rgb : si_rgb;
   assign so_rgb = (bypass_reg) ? si_rgb : chrom_rgb;
endmodule

