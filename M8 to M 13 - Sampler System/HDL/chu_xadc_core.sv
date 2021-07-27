
// Xilinx xadc interface:
//  * xadc in sequence mode
//  * DRP interface is connected to atomtically read
//    out the pres-designated channels
//  * the readout is stored into corresponding register

module chu_xadc_core
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
    // external signals 
    input  logic [3:0] adc_p,
    input  logic [3:0] adc_n
   );

   // signal declaration
   logic [4:0] channel;
   logic [6:0] daddr_in;
   logic eoc;
   logic rdy;
   logic [15:0]  adc_data; 
   logic [15:0] adc0_out_reg, adc1_out_reg, adc2_out_reg, adc3_out_reg;
   logic [15:0] tmp_out_reg , vcc_out_reg ;
   logic [31:0] r_data;
   
   // instantiate xadc
   xadc_fpro xadc_unit (
      .dclk_in(clk),         // input logic dclk_in
      .reset_in(reset),      // input logic reset_in
      .di_in(16'h0000),      // input logic [15 : 0] di_in
      .daddr_in(daddr_in),   // input logic [6 : 0] daddr_in
      .den_in(eoc),          // input logic den_in
      .dwe_in(1'b0),         // input logic dwe_in
      .drdy_out(rdy),        // output logic drdy_out
      .do_out(adc_data),     // output logic [15 : 0] do_out
      .vp_in(1'b0),          // input logic vp_in
      .vn_in(1'b0),          // input logic vn_in
      .vauxp2(adc_p[2]),     // input logic vauxp2
      .vauxn2(adc_n[2]),     // input logic vauxn2
      .vauxp3(adc_p[0]),     // input logic vauxp3
      .vauxn3(adc_n[0]),     // input logic vauxn3
      .vauxp10(adc_p[1]),    // input logic vauxp10
      .vauxn10(adc_n[1]),    // input logic vauxn10
      .vauxp11(adc_p[3]),    // input logic vauxp11
      .vauxn11(adc_n[3]),    // input logic vauxn11
      .channel_out(channel), // output logic [4 : 0] channel_out
      .eoc_out(eoc),         // output logic eoc_out
      .alarm_out(),          // output logic alarm_out
      .eos_out(),            // output logic eos_out
      .busy_out()            // output logic busy_out
   );

   assign daddr_in = {2'b00, channel};
   
   // registers and decoding
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         adc0_out_reg <= 16'h0000;
         adc1_out_reg <= 16'h0000;
         adc2_out_reg <= 16'h0000;
         adc3_out_reg <= 16'h0000;
         tmp_out_reg <= 16'h0000;
         vcc_out_reg <= 16'h0000;
      end 
      else begin
         if (rdy && channel == 5'b10011)
            adc0_out_reg <= adc_data;
         if (rdy && channel == 5'b11010)
            adc1_out_reg <= adc_data;
         if (rdy && channel == 5'b10010)
            adc2_out_reg <= adc_data;
         if (rdy && channel == 5'b11011)
            adc3_out_reg <= adc_data;
         if (rdy && channel == 5'b00000)
            tmp_out_reg <= adc_data;
         if (rdy && channel == 5'b00001)
            vcc_out_reg <= adc_data;
     end
    
   // read multiplexing 
   always_comb
      case(addr[2:0])
         3'b000:
            r_data <= {16'h0000, adc0_out_reg};
         3'b001:
            r_data <= {16'h0000, adc1_out_reg};
         3'b010:
            r_data <= {16'h0000, adc2_out_reg};
         3'b011:
            r_data <= {16'h0000, adc3_out_reg};
         3'b100:
            r_data <= {16'h0000, tmp_out_reg};
         default:
            r_data <= {16'h0000, vcc_out_reg};
      endcase
      assign rd_data = r_data;
endmodule     


