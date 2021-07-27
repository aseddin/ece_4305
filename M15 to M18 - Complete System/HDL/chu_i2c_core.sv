module chu_i2c_core
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
    // external signal    
    output tri scl,
    inout  tri sda 
   );

   // signal declaration
   logic [15:0] dvsr_reg;
   logic wr_i2c, wr_dvsr;
   logic [7:0] dout;
   logic ready, ack; 
   
   // instantiate spi controller
   i2c_master i2c_unit
   (
    .din(wr_data[7:0]), .cmd(wr_data[10:8]),
    .dvsr(dvsr_reg), .done_tick(), .*
   );
       
   // registers
   always_ff @(posedge clk, posedge reset)
      if (reset)
        dvsr_reg <= 0;
      else   
         if (wr_dvsr)
             dvsr_reg <= wr_data[15:0];
   // decoding
   assign wr_dvsr = cs & write & addr[1:0]==2'b01;
   assign wr_i2c  = cs & write & addr[1:0]==2'b10;
   // read data  
   assign rd_data = {22'b0, ack, ready, dout};
endmodule  


