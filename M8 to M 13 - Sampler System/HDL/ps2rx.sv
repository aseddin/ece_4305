module ps2rx
   (
    input  logic clk, reset,
    input  logic ps2d, ps2c, rx_en,
    output logic rx_idle, rx_done_tick,
    output logic [7:0] dout
   );

   // fsm state type 
   typedef enum {idle, dps, load} state_type;

   // declaration
   state_type state_reg, state_next;
   logic [7:0] filter_reg;
   logic [7:0] filter_next;
   logic f_ps2c_reg;
   logic f_ps2c_next;
   logic [3:0] n_reg, n_next;
   logic [10:0] b_reg, b_next;
   logic fall_edge;

   // body
   //*****************************************************************
   // filter and falling-edge tick generation for ps2c
   //*****************************************************************
   always_ff @(posedge clk, posedge reset)
   if (reset) begin
      filter_reg <= 0;
      f_ps2c_reg <= 0;
   end
   else begin
      filter_reg <= filter_next;
      f_ps2c_reg <= f_ps2c_next;
   end

   assign filter_next = {ps2c, filter_reg[7:1]};
   assign f_ps2c_next = (filter_reg==8'b11111111) ? 1'b1 :
                        (filter_reg==8'b00000000) ? 1'b0 :
                         f_ps2c_reg;
   assign fall_edge = f_ps2c_reg & ~f_ps2c_next;
   //*****************************************************************
   // FSMD
   //*****************************************************************
   // state & data registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         state_reg <= idle;
         n_reg <= 0;
         b_reg <= 0;
      end
      else begin
         state_reg <= state_next;
         n_reg <= n_next;
         b_reg <= b_next;
      end
   // next-state logic
   always_comb
   begin
      state_next = state_reg;
      rx_idle = 1'b0;
      rx_done_tick = 1'b0;
      n_next = n_reg;
      b_next = b_reg;
      case (state_reg)
         idle: begin
            rx_idle = 1'b1;
            if (fall_edge & rx_en) begin
               // shift in start bit
               b_next = {ps2d, b_reg[10:1]};
               n_next = 4'b1001;
               state_next = dps;
            end
         end
         dps:  // 8 data + 1 parity + 1 stop
            if (fall_edge) begin
               b_next = {ps2d, b_reg[10:1]};
               if (n_reg==0)
                  state_next = load;
               else
                  n_next = n_reg - 1;
               end
         default: begin // 1 extra clock to complete last shift
            state_next = idle;
            rx_done_tick = 1'b1;
         end
      endcase
   end
   // output
   assign dout = b_reg[8:1];  // data bits
endmodule