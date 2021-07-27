module osd_src 
   #(
    parameter CD = 12,      // color depth
              KEY_COLOR =0  // chroma key
   )
   (
    input  logic clk,
    input  logic [10:0] x, y,   // x-and  y-coordinate    
    // tile ram write port 
    input  logic [6:0] xt,
    input  logic [4:0] yt,
    input  logic [7:0] ch_in, // char data
    input  logic we_ch,       // char write enable
    // forground/background color of char tile
    input  logic [CD-1:0] front_rgb, back_rgb,
    // pixel output
    output logic [CD-1:0] osd_rgb
   );
   
   // localparam declaration
   localparam NULL_CHAR = 7'b0000000; 
   // signal delaration
   // font ROM
   logic [6:0] char_addr;
   logic [10:0] rom_addr;
   logic [3:0] row_addr;
   logic [2:0] bit_addr;
   logic [7:0] font_word;
   // char tile RAM
   logic [11:0] addr_w, addr_r;
   logic [7:0] ch_ram_out;
   logic [7:0] ch_d1_reg;
   // delay line 
   logic [2:0] x_delay1_reg, x_delay2_reg;
   logic [3:0] y_delay1_reg;
   // other signals
   logic font_bit, rev_bit;
   logic [CD-1:0] f_rgb, b_rgb, p_rgb;
     
   // body 
   // *****************************************************************
   // instantiation
   // *****************************************************************
   // instantiate font ROM
   font_rom font_unit (
      .clk(clk), .addr(rom_addr), .data(font_word));
   // instantiate dual port tile RAM (2^12-by-8)
   sync_rw_port_ram #(.ADDR_WIDTH(12), .DATA_WIDTH(8)) text_ram_unit ( 
      .clk(clk),
      // write from main system
      .we(we_ch), .addr_w(addr_w), .din(ch_in),
      // read to vga
      .addr_r(addr_r), .dout(ch_ram_out)
      );
   // tile RAM write
   assign addr_w = {yt, xt};
   // *****************************************************************
   // delay-line registers
   // ***************************************************************** 
   always_ff @(posedge clk) begin
      y_delay1_reg <= y[3:0];
      x_delay1_reg <= x[2:0];
      x_delay2_reg <= x_delay1_reg;
      ch_d1_reg <= ch_ram_out;
   end
   // *****************************************************************
   // pixel data read
   // *****************************************************************
   // tile RAM address
   assign addr_r = {y[8:4], x[9:3]};
   assign char_addr = ch_ram_out[6:0];  // 7 LSBs (ascii code)
   // font ROM
   assign row_addr = y_delay1_reg;           
   assign rom_addr = {char_addr, row_addr};
   // select a bit
   assign bit_addr = x_delay2_reg;   
   assign font_bit = font_word[~bit_addr]; 
   // *****************************************************************
   // pixel color control
   // ***************************************************************** 
   // reverse color control
   assign rev_bit = ch_d1_reg[7];
   assign f_rgb = (rev_bit) ? back_rgb  : front_rgb;
   assign b_rgb = (rev_bit) ? front_rgb : back_rgb;
   // palette circuit 
   assign p_rgb = (font_bit) ? f_rgb : b_rgb;
   // transparency control
   assign osd_rgb = (ch_d1_reg[6:0]==NULL_CHAR) ? KEY_COLOR : p_rgb;
endmodule
