//Listing 8.3
module uart_tx
   #(
    parameter DBIT = 8,     // # data bits
              SB_TICK = 16  // # 16 ticks for 1 stop bit
   )
   (
    input  logic clk, reset,
    input  logic tx_start, s_tick,
    input  logic [7:0] din,
    output logic tx_done_tick,
    output logic tx
   );

   // fsm state type 
   typedef enum {idle, start, data, stop} state_type;

   // signal declaration
   state_type state_reg, state_next;
   logic [3:0] s_reg, s_next;
   logic [2:0] n_reg, n_next;
   logic [7:0] b_reg, b_next;
   logic tx_reg, tx_next;

   // body
   // FSMD state & data registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         state_reg <= idle;
         s_reg <= 0;
         n_reg <= 0;
         b_reg <= 0;
         tx_reg <= 1'b1;
      end
      else begin
         state_reg <= state_next;
         s_reg <= s_next;
         n_reg <= n_next;
         b_reg <= b_next;
         tx_reg <= tx_next;
      end

   // FSMD next-state logic & functional units
   always_comb
   begin
      state_next = state_reg;
      tx_done_tick = 1'b0;
      s_next = s_reg;
      n_next = n_reg;
      b_next = b_reg;
      tx_next = tx_reg ;
      case (state_reg)
         idle: begin
            tx_next = 1'b1;
            if (tx_start) begin
               state_next = start;
               s_next = 0;
               b_next = din;
            end
         end
         start: begin
            tx_next = 1'b0;
            if (s_tick)
               if (s_reg==15) begin
                  state_next = data;
                  s_next = 0;
                  n_next = 0;
               end
               else
                  s_next = s_reg + 1;
         end
         data: begin
            tx_next = b_reg[0];
            if (s_tick)
               if (s_reg==15) begin
                  s_next = 0;
                  b_next = b_reg >> 1;
                  if (n_reg==(DBIT-1))
                     state_next = stop ;
                  else
                     n_next = n_reg + 1;
               end
               else
                  s_next = s_reg + 1;
         end
         stop: begin
            tx_next = 1'b1;
            if (s_tick)
               if (s_reg==(SB_TICK-1)) begin
                  state_next = idle;
                  tx_done_tick = 1'b1;
               end
               else
                 s_next = s_reg + 1;
         end
      endcase
   end
   // output
   assign tx = tx_reg;
endmodule