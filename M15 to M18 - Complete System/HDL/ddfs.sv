module ddfs
   #(parameter PW = 30)       // width of phase accumulator
   (
    input  logic clk, reset,
    input  logic [PW-1:0] fccw, // carrier frequency control word
    input  logic [PW-1:0] focw, // frequency offset control word
    input  logic [PW-1:0] pha,  // phase offset
    input  logic [15:0] env,    // envelop 
    output logic [15:0] pcm_out,
    output logic pulse_out
   );

   // signal declaration
   logic [PW-1:0] fcw, p_next, pcw;
   logic [PW-1:0] p_reg;
   logic [7:0] p2a_raddr;
   logic [15:0] amp;
   logic signed [31:0] modu; 
   logic [15:0] pcm_reg;

   // body
   // instantiate sin ROM
   sin_rom rom_unit
      (.clk(clk), .addr_r(p2a_raddr), .dout(amp));
   // phase register and output buffer
   // output "pipeline" buffer to shorten critical path of *
   always_ff @(posedge clk, posedge reset)
   if (reset) begin
      p_reg <= 0;
      pcm_reg <= 0;
   end   
   else begin
      p_reg <= p_next;
      pcm_reg <= modu[29:14];
   
   end
   // frequency modulation
   assign fcw = fccw + focw;
   // phase accumulation 
   assign p_next = p_reg + fcw;
   // phase modulation
   assign pcw = p_reg + pha;   
   // phase to amplitude mapping address
   assign p2a_raddr = pcw[PW-1:PW-8];
   // amplitude modulation 
   //   envelop 
   //    * in Q2.14 
   //    * -1 < env < +1  (between 1100...00 and 0100...00) 
   //    * Q16.0 * Q2.14 => modu is Q18.14
   //    * convert modu back to Q16.0  
   assign modu = $signed(env) * $signed(amp);  // modulated output 
   assign pcm_out = pcm_reg;
   assign pulse_out = p_reg[PW-1];
endmodule   
   
   // use an output buffer (to shorten crtical path since the o/p feeds dac) 
   // always_ff @(posedge clk)
   //    pcm_reg <= modu[29:14];
