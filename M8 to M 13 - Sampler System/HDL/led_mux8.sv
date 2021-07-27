module led_mux8
   (
    input  logic clk, reset,
    input  logic [7:0] in3, in2, in1, in0,
    input  logic [7:0] in7, in6, in5, in4,
    output logic [7:0] an,   // enable, 1-out-of-8 asserted low
    output logic [7:0] sseg  // led segments
   );

   // constant declaration
   // refreshing rate around 1600 Hz (100MHz/2^16)
   localparam N = 18;

   // declaration
   logic [N-1:0] q_reg, q_next;

   // N-bit counter
   // register
   always_ff @(posedge clk,  posedge reset)
      if (reset)
         q_reg <= 0;
      else
         q_reg <= q_next;

   // next-state logic
   assign q_next = q_reg + 1;

   // 3 MSBs of counter to control 8-to-1 multiplexing
   // and to generate active-low enable signal
   always_comb
      unique case (q_reg[N-1:N-3])
         3'b000: begin
            an = 8'b1111_1110;
            sseg = in0;
         end
         3'b001: begin
            an = 8'b1111_1101;
            sseg = in1;
         end
         3'b010: begin
            an = 8'b1111_1011;
            sseg = in2;
         end
         3'b011: begin
            an = 8'b1111_0111;
            sseg = in3;
         end
         3'b100: begin
            an = 8'b1110_1111;
            sseg = in4;
         end
         3'b101: begin
            an = 8'b1101_1111;
            sseg = in5;
         end
         3'b110: begin
            an = 8'b1011_1111;
            sseg = in6;
         end
         default: begin
            an = 8'b0111_1111;
            sseg = in7;
         end
       endcase
endmodule