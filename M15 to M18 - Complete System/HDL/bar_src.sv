module bar_src (
   input  logic clk,
   input  logic [10:0] x, y,     // treated as x-/y-axis
   output logic [11:0] bar_rgb 
   );

   // signal declaration
   logic [3:0] up, down;
   logic [3:0] r, g, b;
   logic [11:0] reg_d1_reg, reg_d2_reg;
   
   // body
   assign up = x[6:3];
   assign down = ~x[6:3];    // "not" reverse the binary sequence 
   
   always_comb begin
      // 16 shades of gray
      if (y < 128) begin
         r = x[8:5];
         g = x[8:5];
         b = x[8:5];
      end   
      // 8 prime colcor with 50% intensity
      else if (y < 256) begin
         r = {x[8], x[8], 2'b00};
         g = {x[7], x[7], 2'b00};
         b = {x[6], x[6], 2'b00};
      end
      else begin   
      // a continuous color spectrum 
         case (x[9:7]) 
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
   // output with 2-stage delay line
   always_ff @(posedge clk) begin
      reg_d1_reg <= {r, g, b};
      reg_d2_reg <= reg_d1_reg;
   end
   assign bar_rgb = reg_d2_reg;
endmodule