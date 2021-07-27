// fsm to generate ADSR envelop
// start (trigger) signal:
//     - starts the "attack" when asserted
//     - restarts the epoch if aseerted before the current epoch ends 
// amplitudes:
//     - 32-bit unsigned   
//     - use 32 bits to accommodate the needed resolution for "step"
//     - intepreted as Q1.31 format:
//     - rnage artificially limited between 0.0 and 1.0
//     - i.e., 0.0...0 to 1.0...0 (1.0)
//     - 1.1xx...x not allowed
// output: Q2.14 for range (-1.0 to 1.0)
// special atk_step values
//     - atk_step = 11..11: bypass adsr; i.e., envelop=1.0
//     - atk_step = 00..00: output 0; i.e., envelop = 0.0
// Width selection: 
//   max attack time = 2^31 * clock period 

module adsr 
(       
 input  logic clk,
 input  logic reset,
 input  logic start,
 input  logic [31:0] atk_step, dcy_step, sus_level, rel_step,
 input  logic [31:0] sus_time, 
 output logic [15:0] env,
 output logic adsr_idle
);
   // constants
   localparam MAX = 32'h8000_0000;
   localparam BYPASS = 32'hffff_ffff;
   localparam ZERO = 32'h0000_0000;

   // fsm state type 
   typedef enum {idle, launch, attack, decay, sustain, rel} state_type;

   //  declaration
   state_type state_reg, state_next;
   logic [31:0] a_reg, t_reg;
   logic [31:0] a_next, t_next;
   logic [31:0] n_tmp;
   logic fsm_idle;
   logic [31:0] env_i;
   
   // state and data registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         state_reg <= idle;
         a_reg <= 32'h0;
         t_reg <= 32'h0;
      end   
      else begin
         state_reg <= state_next;
         a_reg <= a_next;
         t_reg <= t_next;
      end   
      
   // fsmd next-state logic and data path logic
   always_comb
   begin
      state_next = state_reg;
      a_next     = a_reg;
      t_next = t_reg;
      fsm_idle  = 1'b0;
      case (state_reg)
         idle: begin
            fsm_idle = 1'b1;
            if (start)
               state_next = launch;
         end
         launch: begin
            state_next = attack;
            a_next = 32'b0;
         end
         attack: begin
            if (start) 
               state_next = launch;
            else begin
               n_tmp = a_reg + atk_step;
               if (n_tmp < MAX) 
                  a_next = n_tmp;
               else
                  state_next = decay;
            end;   
         end
         decay: begin
            if (start) 
               state_next = launch;
            else begin
               n_tmp = a_reg - dcy_step;
               if (n_tmp > sus_level) 
                  a_next = n_tmp;
               else begin
                  a_next = sus_level;
                  state_next = sustain;
                  t_next = 32'b0;   // start timer
               end
            end;   
         end
         sustain: begin
            if (start) 
               state_next = launch;
            else 
               if (t_reg < sus_time) 
                  t_next = t_next + 1;
               else
                  state_next = rel;
         end
         default: begin
            if (start) 
               state_next = launch;
            else 
               if (a_reg > rel_step) 
                  a_next = a_reg - rel_step;
               else
                  state_next = idle;
         end
      endcase
   end
   assign adsr_idle = fsm_idle;
   // special cases
   assign env_i = (atk_step == BYPASS) ? MAX :
                  (atk_step == ZERO) ? 32'b0 : 
                  a_reg;
   assign env = {1'b0, env_i[31:17]};
endmodule
