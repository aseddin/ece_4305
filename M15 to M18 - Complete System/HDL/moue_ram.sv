module mouse_ram_lut
   #(
    parameter DATA_WIDTH = 12, // color depth
              ADDR_WIDTH = 10  // number of address bits
   )
   (
    input  logic clk,
    input  logic we,
    input  logic [ADDR_WIDTH-1:0] addr_r,
    input  logic [ADDR_WIDTH-1:0] addr_w,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
   );

   // declaration
   logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];
   logic [DATA_WIDTH-1:0] data_reg;
   
   // mouse_pointer.txt specifies the initial values of ram 
   initial 
      $readmemh("mouse_pointer.txt", ram);
      
   // body
   always_ff @(posedge clk)
   begin
      if (we)
         ram[addr_w] <= din;
      data_reg <= ram[addr_r];
   end
   assign dout = data_reg;
endmodule
   
