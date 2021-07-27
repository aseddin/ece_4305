/*-======================================================================
-- Description: generate a 3-level test bar pattern:
--   * gray scale 
--   * 8 prime colors
--   * a continuous color spectrum
--   * it is customized for 12-bit VGA
--   * two registers form 2-clock delay line  
--======================================================================*/

module bar_demo 
   (
    input  logic [10:0] x, y,     // treated as x-/y-axis
    output logic [11:0] bar_rgb 
   );

   // declaration
   logic [3:0] up, down;
   logic [3:0] r, g, b;
   
   // body
   assign up = x[6:3];
   assign down = ~x[6:3];    // "not" reverse the binary sequence 
   always_comb
   begin
      // 16 shades of gray
      if (y < 128) begin
         r = x[8:5];
         g = x[8:5];
         b = x[8:5];
      end   
      // 8 prime colors with 50% intensity
      else if (y < 256) begin
         r = {x[8], x[8], 2'b00};
         g = {x[7], x[7], 2'b00};
         b = {x[6], x[6], 2'b00};
      end
      else begin   
      // a continuous color spectrum 
      // width of up/sown can be increased to accommodate finer spectrum
      // see Fig 23 of http://en.wikipedia.org/wiki/HSL_and_HSV
      unique case (x[9:7]) 
         3'b000: begin
            r = 4'b1111;
            g = up;
            b = 4'b0000;
         end   
         3'b001: begin
            r = down;
            g = 4'b1111;
            b = 4'b0000;
         end   
         3'b010: begin
            r = 4'b0000;
            g = 4'b1111;
            b = up;
         end   
         3'b011: begin
            r = 4'b0000;
            g = down;
            b = 4'b1111;
         end   
         3'b100: begin
            r = up;
            g = 4'b0000;
            b = 4'b1111;
         end   
         3'b101: begin
            r = 4'b1111;
            g = 4'b0000;
            b = down;
         end   
         default: begin
            r = 4'b1111;
            g = 4'b1111;
            b = 4'b1111;
         end  
         endcase
      end // else
   end // always   
   // output
   assign bar_rgb = {r, g, b};
endmodule