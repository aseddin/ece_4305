module mouse_src 
   #(
    parameter CD = 12,      // color depth
              ADDR = 10,    // number of address bits
              KEY_COLOR =0  // chroma key
   )
   (
    input  logic clk,
    input  logic [10:0] x, y,   // x-and  y-coordinate    
    input  logic [10:0] x0, y0, // origin of sprite 
    // sprite ram write 
    input  logic we ,
    input  logic [ADDR-1:0] addr_w,
    input  logic [CD-1:0] pixel_in,
    // pixel output
    output logic [CD-1:0] mouse_rgb
   );
   
   // localparam declaration
   localparam H_SIZE = 32; // horizontal size of sprite
   localparam V_SIZE = 32; // vertical size of sprite
   // signal delaration
   logic signed [11:0] xr, yr;  // relative x/y position
   logic in_region;
   logic [ADDR-1:0] addr_r;
   logic [CD-1:0] full_rgb, out_rgb;
   logic [CD-1:0] out_rgb_d1_reg;
   
   // body
   // instantiate sprite RAM
   mouse_ram_lut #(.ADDR_WIDTH(ADDR),.DATA_WIDTH(CD)) ram_unit (
      .clk(clk), .we(we), .addr_w(addr_w), .din(pixel_in),
      .addr_r(addr_r), .dout(full_rgb));
   // relative coordinate calculation
   assign xr = $signed({1'b0, x}) - $signed({1'b0, x0});
   assign yr = $signed({1'b0, y}) - $signed({1'b0, y0});
   assign addr_r = {yr[4:0], xr[4:0]};
   // in-region comparison and multiplexing 
   assign in_region = (0<= xr) && (xr<H_SIZE) && (0<=yr) && (yr<V_SIZE);
   assign out_rgb = in_region ? full_rgb : KEY_COLOR;
   // output with a-stage delay line
   always_ff @(posedge clk) 
      out_rgb_d1_reg <= out_rgb;
   assign mouse_rgb = out_rgb_d1_reg;
endmodule
