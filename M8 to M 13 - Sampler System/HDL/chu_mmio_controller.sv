module chu_mmio_controller 
(  
   // FPro bus 
   input  logic clk,
   input  logic reset,
   input  logic mmio_cs,
   input  logic mmio_wr,
   input  logic mmio_rd,
   input  logic [20:0] mmio_addr, // 11 LSB used; 2^6 slot/2^5 reg each 
   input  logic [31:0] mmio_wr_data,
   output logic [31:0] mmio_rd_data,
   // slot interface
   output logic [63:0] slot_cs_array,
   output logic [63:0] slot_mem_rd_array,
   output logic [63:0] slot_mem_wr_array,
   output logic [4:0]  slot_reg_addr_array [63:0],
   input  logic  [31:0] slot_rd_data_array [63:0], 
   output logic [31:0] slot_wr_data_array [63:0]
);

   // declaration
   logic [5:0] slot_addr;
   logic [4:0] reg_addr;

   // body
   assign slot_addr = mmio_addr[10:5];
   assign reg_addr  = mmio_addr[4:0];

   // address decoding
   always_comb
   begin
      slot_cs_array = 0;
      if (mmio_cs)
         slot_cs_array[slot_addr] = 1;
   end
   
   // broadcast to all slots 
   generate
      genvar i;
      for (i=0; i<64; i=i+1) 
      begin:  slot_signal_gen
         assign slot_mem_rd_array[i] = mmio_rd;
         assign slot_mem_wr_array[i] = mmio_wr;
         assign slot_wr_data_array[i] = mmio_wr_data;
         assign slot_reg_addr_array[i] = reg_addr;
      end
   endgenerate
   // mux for read data 
   assign mmio_rd_data = slot_rd_data_array[slot_addr];   
endmodule

/*
   logic  [63:0] slot_cs_tmp;

   // body
   assign slot_addr = mmio_addr[10:5];
   assign reg_addr  = mmio_addr[4:0];

   // address decoding
   always_comb
   begin
      slot_cs_tmp = 0;
      if (mmio_cs)
         slot_cs_tmp[slot_addr] = 1;
   end
   assign slot_cs_array = slot_cs_tmp;
   
*/
/*
interface ClockedBus (input Clk);
  logic[7:0] Addr, Data;
  logic RWn;
endinterface

module RAM (ClockedBus Bus);
  always @(posedge Bus.Clk)
    if (Bus.RWn)
      Bus.Data = mem[Bus.Addr];
    else
      mem[Bus.Addr] = Bus.Data;
endmodule

// Using the interface
module Top;
  reg Clock;

  // Instance the interface with an input, using named connection
  ClockedBus TheBus (.Clk(Clock));
  RAM TheRAM (.Bus(TheBus));
  ...
endmodule
*/

/********** array of interfaces not working **********************
interface mmio_slot_intf (input clk, int reset);
   // slot interface
   logic cs;
   logic read;
   logic write;
   logic [4:0] addr;
   logic [31:0] wr_data;
   logic [31:0] rd_data;
endinterface

module chu_mmio_controller 
(  
   // FPro bus 
   input logic clk,
   input logic reset,
   input logic mmio_cs,
   input logic mmio_wr,
   input logic mmio_rd,
   input logic [20:0] mmio_addr, //only lower 11 LSB used; 2^6 slots with 2^5 reg each 
   input logic [31:0] mmio_wr_data,
   output logic [31:0] mmio_rd_data,
   // 64 slot interface
   mmio_slot_intf  ctrl_slots [5:0]
);

   // declaration
   logic [5:0] slot_addr;
   logic [4:0] reg_addr;
   logic  [63:0] slot_cs_tmp;
   logic  [31:0] slot_rd_data_array [63:0];

   // body
   assign slot_addr = mmio_addr[10:5];
   assign reg_addr  = mmio_addr[4:0];
   

   // mux for read data 
   // assign mmio_rd_data = ctrl_slots[slot_addr].rd_data;  // must be constnat index 
   genvar i;
   generate
      for (i=0; i<64; i=i+1) 
      begin:  slot_rd_data_gen
         assign slot_rd_data_array[i] =ctrl_slots[i].rd_data;
      end
   endgenerate
   // assign mmio_rd_data = ctrl_slots[0].rd_data;
   assign mmio_rd_data = slot_rd_data_array[slot_addr];
  

endmodule


*/