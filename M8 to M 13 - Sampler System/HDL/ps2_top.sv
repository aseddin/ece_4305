module ps2_top
   #(parameter W_SIZE = 6)   // # address bits in FIFO buffer
   (
    input  logic clk, reset,
    input  logic wr_ps2, rd_ps2_packet,
    input  logic [7:0] ps2_tx_data,
    output logic [7:0] ps2_rx_data,
    output logic ps2_tx_idle, ps2_rx_buf_empty,
    inout  tri ps2d, ps2c
   );

   // declaration
   logic rx_idle, tx_idle, rx_done_tick;
   logic [7:0] rx_data;

   // body
   // instantiate ps2 transmitter
   ps2tx ps2_tx_unit
      (.*, .din(ps2_tx_data), .tx_done_tick());
   // instantiate ps2 receiver
   ps2rx ps2_rx_unit
      (.*, .rx_en(tx_idle),.dout(rx_data));
   // instantiate FIFO buffer
   fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(W_SIZE)) fifo_unit
      (.clk(clk), .reset(reset), .rd(rd_ps2_packet),
       .wr(rx_done_tick), .w_data(rx_data), .empty(ps2_rx_buf_empty),
       .full(), .r_data(ps2_rx_data));
   //output 
   assign ps2_tx_idle = tx_idle;
endmodule
