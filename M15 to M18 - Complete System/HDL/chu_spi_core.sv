module chu_spi_core
   #(parameter S = 2)  // width (# bits) of output port
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
    output logic spi_sclk,
    output logic spi_mosi,
    input  logic spi_miso,
    output logic [S-1:0] spi_ss_n 
   );

   // signal declaration
   logic wr_en, wr_ss, wr_spi, wr_ctrl;
   logic [17:0] ctrl_reg;
   logic [S-1:0] ss_n_reg;
   logic [7:0] spi_out;
   logic spi_ready, cpol, cpha; 
   logic [15:0] dvsr;
   
   // instantiate spi controller
   spi spi_unit(
    .clk(clk), .reset(reset), 
    .din(wr_data[7:0]),
    .dvsr(dvsr),
    .start(wr_spi),
    .cpol(cpol),
    .cpha(cpha),
    .dout(spi_out),
    .sclk(spi_sclk),
    .miso(spi_miso),
    .mosi(spi_mosi),
    .spi_done_tick(),
    .ready(spi_ready)
   );
       
   // registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         ctrl_reg <= 17'h0_0200;    // dvsr=1028 (about 50 KHz sclk for 100MHz clk)  
         ss_n_reg <= {S{1'b1}};     // de-assert all ss_n
      end 
      else begin
         if (wr_ctrl)
             ctrl_reg <= wr_data[17:0];
         if (wr_ss)
             ss_n_reg <= wr_data[S-1:0];
      end
   // decoding
   assign wr_en = cs & write ;
   assign wr_ss = wr_en && addr[1:0]==2'b01;
   assign wr_spi = wr_en && addr[1:0]==2'b10;
   assign wr_ctrl = wr_en && addr[1:0]==2'b11;
   // control signals 
   assign dvsr = ctrl_reg[15:0];
   assign cpol = ctrl_reg[16];
   assign cpha = ctrl_reg[17];
   assign spi_ss_n = ss_n_reg;
   // read multiplexing 
   assign  rd_data = {23'b0, spi_ready, spi_out};
endmodule  
