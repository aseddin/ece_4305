module chu_led_mux_core
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external ports
    output logic [7:0] sseg, an
   );

   // declaration
   logic [31:0] d0_reg, d1_reg;
   logic wr_en, wr_d0, wr_d1;
   
   // instantiate led multplexing circuit
   led_mux8  led_mux8_unit (
    .clk(clk), .reset(reset), 
    .in7(d1_reg[31:24]), .in6(d1_reg[23:16]), 
    .in5(d1_reg[15:8]),  .in4(d1_reg[7:0]),
    .in3(d0_reg[31:24]), .in2(d0_reg[23:16]), 
    .in1(d0_reg[15:8]),  .in0(d0_reg[7:0]),
    .sseg(sseg), .an(an)
   );
       
   // registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         d0_reg <= 0;
         d1_reg <= 0;
      end 
      else begin
         if (wr_d0)
            d0_reg <= wr_data;
         if (wr_d1)
            d1_reg <= wr_data;
     end
   // decoding
   assign wr_d0 = write & cs & ~addr[0];
   assign wr_d1 = write & cs & addr[0];
   // read data (unused)
   assign rd_data = 0;
endmodule  

