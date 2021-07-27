module mcs_top_vanilla
#(parameter BRG_BASE = 32'hc000_0000)	
(
   input logic clk,
   input logic reset_n,
   // switches and LEDs
   input logic [15:0] sw,
   output logic [15:0] led,
   // uart
   input logic rx,
   output logic tx          
);

   // declaration
   logic clk_100M;
   logic reset_sys;
   // MCS IO bus
   logic io_addr_strobe;
   logic io_read_strobe;
   logic io_write_strobe;
   logic [3:0] io_byte_enable;
   logic [31:0] io_address;
   logic [31:0] io_write_data;
   logic [31:0] io_read_data;
   logic io_ready;
   // fpro bus 
   logic fp_mmio_cs; 
   logic fp_wr;      
   logic fp_rd;     
   logic [20:0] fp_addr;       
   logic [31:0] fp_wr_data;    
   logic [31:0] fp_rd_data;    

   // body
   assign clk_100M = clk;                  // 100 MHz external clock
   assign reset_sys = !reset_n;
   
   //instantiate uBlaze MCS
   cpu cpu_unit (
    .Clk(clk_100M),                     // input wire Clk
    .Reset(reset_sys),                  // input wire Reset
    .IO_addr_strobe(io_addr_strobe),    // output wire IO_addr_strobe
    .IO_address(io_address),            // output wire [31 : 0] IO_address
    .IO_byte_enable(io_byte_enable),    // output wire [3 : 0] IO_byte_enable
    .IO_read_data(io_read_data),        // input wire [31 : 0] IO_read_data
    .IO_read_strobe(io_read_strobe),    // output wire IO_read_strobe
    .IO_ready(io_ready),                // input wire IO_ready
    .IO_write_data(io_write_data),      // output wire [31 : 0] IO_write_data
    .IO_write_strobe(io_write_strobe)   // output wire IO_write_strobe
   );
    
   // instantiate bridge
   chu_mcs_bridge #(.BRG_BASE(BRG_BASE)) bridge_unit (.*, .fp_video_cs());
    
   // instantiated i/o subsystem
   mmio_sys_vanilla #(.N_SW(16),.N_LED(16)) mmio_unit (
   .clk(clk),
   .reset(reset_sys),
   .mmio_cs(fp_mmio_cs),
   .mmio_wr(fp_wr),
   .mmio_rd(fp_rd),
   .mmio_addr(fp_addr), 
   .mmio_wr_data(fp_wr_data),
   .mmio_rd_data(fp_rd_data),
   .sw(sw),
   .led(led),
   .rx(rx),
   .tx(tx)          
  );   
endmodule    

