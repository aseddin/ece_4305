module debounce_fsm
   (
    input  logic clk, reset,
    input  logic btn,
    input  logic ms10_tick,
    output logic db
   );

   // fsm state type 
   typedef enum {zero, wait1_1, wait1_2, wait1_3, 
                 one, wait0_1, wait0_2, wait0_3 } state_type;

   // signal declaration
   state_type state_reg, state_next;
 
   // state register
   always_ff @(posedge clk, posedge reset)
      if (reset)
         state_reg <= zero;
      else
         state_reg <= state_next;

   // next-state logic and output logic
   always_comb 
   begin
      state_next = state_reg;  
      db = 1'b0;              
      case (state_reg)
         zero:
            if (btn)
               state_next = wait1_1;
         wait1_1:
            if (~btn)
               state_next = zero;
            else
               if (ms10_tick)
                  state_next = wait1_2;
         wait1_2:
            if (~btn)
               state_next = zero;
            else
               if (ms10_tick)
                  state_next = wait1_3;
         wait1_3:
            if (~btn)
               state_next = zero;
            else
               if (ms10_tick)
                  state_next = one;
         one:
            begin
              db = 1'b1;
              if (~btn)
                 state_next = wait0_1;
            end
         wait0_1:
            begin
               db = 1'b1;
               if (btn)
                  state_next = one;
               else
                 if (ms10_tick)
                    state_next = wait0_2;
            end
         wait0_2:
            begin
               db = 1'b1;
               if (btn)
                  state_next = one;
               else
                 if (ms10_tick)
                    state_next = wait0_3;
            end
         wait0_3:
            begin
               db = 1'b1;
               if (btn)
                  state_next = one;
               else
                 if (ms10_tick)
                    state_next = zero;
            end
         default: state_next = zero;
      endcase
   end
endmodule