module uart
   #(
    parameter DBIT = 8,      // # data bits
              SB_TICK = 16,  // # 16 ticks for 1 stop bit
              FIFO_W = 2     // # addr bits of FIFO
   )
   (
    input logic clk, reset,
    input logic rd_uart, wr_uart, rx,
    input logic [7:0] w_data,
    input logic [10:0] dvsr,
    output logic tx_full, rx_empty, tx,
    output logic [7:0] r_data
   );

   // signal declaration
   logic tick, rx_done_s_tick, tx_done_tick;
   logic tx_empty, tx_fifo_not_empty;
   logic [7:0] tx_fifo_out, rx_data_out;

   //body
   baud_gen baud_gen_unit (.*);

   uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
      (.*, .s_tick(tick), .dout(rx_data_out));

   uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
      (.*, .s_tick(tick), .tx_start(tx_fifo_not_empty), .din(tx_fifo_out));

   fifo #(.DATA_WIDTH(DBIT), .ADDR_WIDTH(FIFO_W)) fifo_rx_unit
      (.*, .rd(rd_uart), .wr(rx_done_tick), .w_data(rx_data_out),
       .empty(rx_empty), .full(), .r_data(r_data));

   fifo #(.DATA_WIDTH(DBIT), .ADDR_WIDTH(FIFO_W)) fifo_tx_unit
      (.*, .rd(tx_done_tick), .wr(wr_uart), .w_data(w_data), .empty(tx_empty),
       .full(tx_full), .r_data(tx_fifo_out));

   assign tx_fifo_not_empty = ~tx_empty;
endmodule

