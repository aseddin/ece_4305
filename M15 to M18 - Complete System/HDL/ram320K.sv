//===
// VGA frame buffer 
//     - 640*480 = 307,200 = 0x4b000 
//     - 19-bit address
//     - infer 512K simple RAM with 200K wasted   
//     - better alternative: use 2 ram modules (256K+64K = 320K)       
//     - required memory = 320K * color depth
module vga_ram
   #(parameter DW = 9) // data width 
  (
    input  logic clk,
    input  logic we,
    input  logic [18:0] addr_w, 
    input  logic [18:0] addr_r, 
    input  logic [DW-1:0] data_w,
    output logic [DW-1:0] data_r
   );
 
   // signal declaration
   logic [DW-1:0] data_r_256k, data_r_64k;
   logic we_256k, we_64k;
   
   // body 
   // instantiate 64K RAM
   sync_rw_port_ram #(.ADDR_WIDTH(18), .DATA_WIDTH(DW)) ram_256k_unit ( 
      .clk(clk), .we(we_256k), .addr_w(addr_w[17:0]), .din(data_w),
      .addr_r(addr_r[17:0]), .dout(data_r_256k)
   );
   // instantiate 256K RAM
   sync_rw_port_ram #(.ADDR_WIDTH(16), .DATA_WIDTH(DW)) ram_64k_unit ( 
      .clk(clk), .we(we_64k), .addr_w(addr_w[15:0]), .din(data_w),
      .addr_r(addr_r[15:0]), .dout(data_r_64k)
   );
   // read data multiplexing
   assign data_r = (addr_r[18]) ? data_r_64k : data_r_256k;
   // write decoding
   assign we_256k = we & ~addr_w[18];
   assign we_64k  = we & addr_w[18];
endmodule   
     
