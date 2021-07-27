module chu_vga_osd_core 
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

   // signal delaration
   logic wr_en, wr_reg, wr_bypass, wr_fg_color, wr_bg_color, wr_char_ram;
   logic [CD-1:0] osd_rgb;
   logic [CD-1:0] fg_color_reg, bg_color_reg;
   logic bypass_reg;
   
   // body
   // instantiate osd generator
   osd_src #(.CD(CD)) osd_src_unit (
      .clk(clk), .x(x), .y(y), .xt(addr[6:0]), .yt(addr[11:7]),
      .ch_in(wr_data[7:0]), .we_ch(wr_char_ram),
      .front_rgb(fg_color_reg), .back_rgb(bg_color_reg), 
      .osd_rgb(osd_rgb));
   // register  
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         fg_color_reg <= -1; // 11..11
         bg_color_reg <= 0;
         bypass_reg <= 0;
      end   
      else begin
         if (wr_fg_color)
            fg_color_reg <= wr_data[CD-1:0];
         if (wr_bg_color)
            bg_color_reg <= wr_data[CD-1:0];
         if (wr_bypass)
            bypass_reg <= wr_data[0];
      end      
   // decoding 
   assign wr_en = write & cs;
   assign wr_char_ram = ~addr[13] && wr_en;
   assign wr_reg = addr[13] && wr_en;
   assign wr_bypass   = wr_reg && (addr[1:0]==2'b00);
   assign wr_fg_color = wr_reg && (addr[1:0]==2'b01);
   assign wr_bg_color = wr_reg && (addr[1:0]==2'b10);
   // chrome-key blending and multiplexing
   assign so_rgb = (bypass_reg || osd_rgb==KEY_COLOR) ? si_rgb : osd_rgb;
endmodule   
