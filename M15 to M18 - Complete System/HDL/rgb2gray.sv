/*=======================================================
- gray = 0.21R + 0.72G + 0.07B
- Q4.0 * Q0.8 => Q4.8
- green: g*.72 => g*.72*256 => g*0xb8 
=======================================================*/
module rgb2gray (
   input  logic [11:0] color_rgb,
   output logic [11:0] gray_rgb);

   // localparam declaration
   localparam RW = 8'h35; // weight for red
   localparam GW = 8'hb8; // weight for green
   localparam BW = 8'h12; // weight for blue
   // signal declaration
   logic [3:0] r, g, b, gray;
   logic [11:0] gray12;

   // body
   assign r = color_rgb[11:8];
   assign g = color_rgb[7:4];
   assign b = color_rgb[3:0];
   assign gray12 = r * RW + g * GW + b * BW;
   assign gray = gray12[11:8];
   assign gray_rgb = {gray, gray, gray};
endmodule
