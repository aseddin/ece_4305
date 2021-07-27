module font_rom
   #(
    parameter DATA_WIDTH = 8, 
              ADDR_WIDTH = 11  
   )
   (
    input  logic clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
   );

   // declaration
   logic [DATA_WIDTH-1:0] rom [0:2**ADDR_WIDTH-1];
   logic [DATA_WIDTH-1:0] data_reg;
   
   // font.txt specifies the initial values of ram 
   initial 
      $readmemb("font.txt", rom);
      
   // body
   always_ff @(posedge clk)
      data_reg <= rom[addr];
   assign data = data_reg;
endmodule