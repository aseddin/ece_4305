//  * Reg map;
//    * 00: read (32 LSB of counter)
//    * 01: read (16 MSB of counter)
//    * 10: control register: 
//        bit 0: go/pause
//        bit 1: clear (no memory, just used to generate a 1-clock pulse)
//  * 48-bit counter (up to 65 days)

module chu_timer
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data
   );
   
   // signal declaration
   logic [47:0] count_reg;
   logic ctrl_reg;
   logic wr_en, clear, go;
   
   //***************************************************************
   // counter
   //***************************************************************
   always_ff @(posedge clk, posedge reset)
      if (reset)
         count_reg <= 0;
      else   
         if (clear)
            count_reg <=0;
         else if (go)
            count_reg <= count_reg + 1;
            
   //***************************************************************
   // wrapping circuit
   //***************************************************************
   // ctrl register
   always_ff @(posedge clk, posedge reset)
      if (reset)
         ctrl_reg <= 0;
      else   
         if (wr_en)
            ctrl_reg <= wr_data[0];
   // decoding logic
   assign wr_en = write && cs && (addr[1:0]==2'b10);
   assign clear = wr_en && wr_data[1];
   assign go    = ctrl_reg;
   // slot read interface
   assign rd_data = (addr[0]==0)?
                    count_reg[31:0]:
                    {16'h0000, count_reg[47:32]};
endmodule
