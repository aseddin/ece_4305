
//======================================================================
// Description: wrapper for Xilinx Artix-7 dual-clock BRAM FIFO  buffer 
// Xilinx info:
//   * FIFO_DUALCLOCK_MACRO
//   * cut/paste from Xilinx HDL Language Template, version 2016.4
// Design:
//   * to be used in line buffer
//   * use FWFT (first-word-fall-through mode):
//     read data "showing ahead" (read signal acts as acknowledge 
//     to remove the data from the head of fifo) 
//   * use a 18Kb BRAM
//   * 1024 words
//   * 10-18 bits in a word 
// Note:
//   * The BRAM FIFO is a hard macro and uses no external logic cells
//   * Constraints on FIFO size/depth 
//   * Dummy rdcount/wrcount signals (instead of "open") needed because of 
//     the formal signals are defined as unconstrainted signals 
//   * Use the exact case in generic values 
//   * BRAM FIFO reset signal must connected to a phsyical signal (i.e., not 0)
//     or a DRC error issued when genertaing bit stream 
//======================================================================
// original Xilinx header 
// FIFO_DUALCLOCK_MACRO: Dual Clock First-In, First-Out (FIFO) RAM Buffer
//                       Artix-7
// Xilinx HDL Language Template, version 2016.4

/////////////////////////////////////////////////////////////////
// DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
// ===========|===========|============|=======================//
//   37-72    |  "36Kb"   |     512    |         9-bit         //
//   19-36    |  "36Kb"   |    1024    |        10-bit         //
//   19-36    |  "18Kb"   |     512    |         9-bit         //
//   10-18    |  "36Kb"   |    2048    |        11-bit         //
//   10-18    |  "18Kb"   |    1024    |        10-bit         //
//    5-9     |  "36Kb"   |    4096    |        12-bit         //
//    5-9     |  "18Kb"   |    2048    |        11-bit         //
//    1-4     |  "36Kb"   |    8192    |        13-bit         //
//    1-4     |  "18Kb"   |    4096    |        12-bit         //
/////////////////////////////////////////////////////////////////
//======================================================================

module bram_fifo_fpro 
   #(parameter DW=13) // -- # data width (bits per word; 10-18) 
   (
      input logic reset,
      // read port 
      input  logic clk_rd,           // read clock
      output logic empty,            // read port empty 
      output logic almost_empty,     // read port almost empty 
      input  logic rd_ack,           // read acknowledge
      output logic [DW-1:0] rd_data, // read data
      // write port
      input  logic clk_wr,           // write clock
      output logic full,             // write port full 
      output logic almost_full,      // write port almost full 
      input  logic wr_en,            // write enable 
      input  logic [DW-1:0] wr_data, // write data
      // occupancy of fifo
      output logic [9:0] rdcount,    // read count
      output logic [9:0] wrcount     // write count
   );

   // xilinx macro instantiation 
   FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET(9'h080),    // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET(9'h080),     // Sets almost full threshold
    .DATA_WIDTH(DW),                 // 1-72 for 18Kb / 37-72 for 36Kb
    .DEVICE("7SERIES"),              // Target device: "7SERIES" 
    .FIFO_SIZE ("18Kb"),             // Target BRAM: "18Kb" or "36Kb" 
    .FIRST_WORD_FALL_THROUGH ("TRUE") 
   ) bram_fifo_unit (
    .RST(reset), 
    // read port      
    .RDCLK(clk_rd),              // read clock
    .DO(rd_data),                // read data out  
    .RDEN(rd_ack),               // remove word from head
    .EMPTY(empty),               // fifo empty  
    .ALMOSTEMPTY(almost_empty),   
    .RDCOUNT(rdcount),       
    .RDERR(),                    // read error
    // write port
    .WRCLK(clk_wr),              // write clock
    .DI(wr_data),                // write data in
    .WREN(wr_en),                // write enable
    .FULL(full),                 // fifo full 
    .ALMOSTFULL(almost_full),    
    .WRCOUNT(wrcount),   
    .WRERR()                     // write error
   );
endmodule   