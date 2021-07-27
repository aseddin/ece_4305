module chu_ps2_core
   #(parameter W_SIZE = 6)   // # address bits in FIFO buffer
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external ports    
    inout  tri ps2d, ps2c
   );

   // declaration
   logic [7:0] ps2_rx_data;
   logic rd_fifo, ps2_rx_buf_empty;
   logic wr_ps2, ps2_tx_idle;

   // body
   // instantiate PS2 controller   
   ps2_top #(.W_SIZE(W_SIZE)) ps2_unit
      (.*, .rd_ps2_packet(rd_fifo), .ps2_tx_data(wr_data[7:0])); 
   
   // decoding and read multiplexing
   // remove an item from FIFO  
   assign rd_fifo = cs & write & (addr[1:0]==2'b10);
   // write data to PS2 transmitting subsystem  
   assign wr_ps2 = cs & write & (addr[1:0]==2'b01);
   //  read data multiplexing
   assign rd_data = {22'b0, ps2_tx_idle, ps2_rx_buf_empty, ps2_rx_data}; 
endmodule  
