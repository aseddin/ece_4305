//======================================================================
// Description: line buffer for pixel data stream
// Design:
//   * to accomodate xilinx bram fifo buffer, the size is fixed at 1024
//   * use almost_full rather than full to provide some cushion in 
//     processinf pipeline (e.g., some pixels may be partially processed)
// Note:
//   * the size of buffer is about a horizontal line to take advantage of
//     extra cusshion time in horizontal sync retrace interval
//======================================================================
module line_buffer 
   #(parameter CD = 12)    // color depth
   (
    input  logic clk_stream_in,
    input  logic clk_stream_out,
    input  logic reset,
    // stream in (sink)
    input  logic[CD:0] si_data,  // color+start
    input  logic si_valid,
    output logic si_ready,
    // stream out (source)
    output logic[CD:0] so_data,  // color+start
    output logic so_valid,
    input  logic so_ready
   );
   
   // constant declaration
   localparam DW = CD + 1; // data width=colors+start 
   // signal delaration
   logic almost_full, empty;
   logic fifo_wr_en, fifo_rd_ack;
   logic [9:0] rdcount, wrcount;
   
   // instantiate dual-clock fifo
   bram_fifo_fpro #(.DW(DW)) line_fifo_unit 
   (
    .reset(reset),
    // read port 
    .clk_rd(clk_stream_out),
    .rd_data(so_data),
    .rd_ack(fifo_rd_ack),  
    .empty(empty),
    .almost_empty(),
    .rdcount(rdcount),
    // write port
    .clk_wr(clk_stream_in),
    .wr_data(si_data),
    .wr_en(fifo_wr_en),
    .full(),
    .almost_full(almost_full),
    .wrcount(wrcount)
   );
   // stream interface signals   
   assign fifo_wr_en = si_valid;
   assign si_ready = ~almost_full;
   assign so_valid = ~empty;
   assign fifo_rd_ack = so_ready;
endmodule
