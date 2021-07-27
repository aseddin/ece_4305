module chu_gpi
   #(parameter W = 8) // width of input port
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
    input logic [W-1:0] din
   );

   // signal declaration
   logic [W-1:0] rd_data_reg;

   // body
   always_ff @(posedge clk, posedge reset)
      if (reset)
         rd_data_reg <= 0;
      else   
         rd_data_reg <= din;
       
   assign rd_data[W-1:0] = rd_data_reg;
   assign rd_data[31:W] = 0;
endmodule

