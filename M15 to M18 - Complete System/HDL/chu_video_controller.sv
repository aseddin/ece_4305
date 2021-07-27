module chu_video_controller (
   input  logic video_cs,
   input  logic video_wr,
   input  logic [20:0] video_addr, 
   input  logic [31:0] video_wr_data,
   // MM frame buffer interface 
   output logic frame_cs,
   output logic frame_wr,
   output logic [19:0] frame_addr,
   output logic [31:0] frame_wr_data,
   // MM video core slot interface
   output logic [7:0] slot_cs_array,     
   output logic [7:0] slot_mem_wr_array, 
   output logic [13:0] slot_reg_addr_array [7:0],
   output logic [31:0] slot_wr_data_array [7:0]
);

   // signal declaration
   logic [2:0] slot_addr;
   logic [13:0] reg_addr;
   logic [7:0] slot_cs_tmp;
   logic [31:0] slot_rd_data_array [63:0];

   // body
   assign slot_addr = video_addr[16:14];
   assign reg_addr = video_addr[13:0];
   assign frame_cs = video_cs & video_addr[20];
   assign slot_cs = video_cs & ~video_addr[20];
   
   // address decoding
   always_comb
   begin	
      slot_cs_tmp = 0;
      if (slot_cs)
         slot_cs_tmp[slot_addr] = 1;
   end
   assign slot_cs_array = slot_cs_tmp;
   // frame buffer
   assign frame_addr = video_addr[19:0];
   assign frame_wr = video_wr;
   assign frame_wr_data = video_wr_data;
   // broadcast to all video slots 
   generate
      genvar i;
      for (i=0; i<8; i=i+1) begin
         assign slot_mem_wr_array[i] = video_wr;
         assign slot_wr_data_array[i] = video_wr_data;
         assign slot_reg_addr_array[i] = reg_addr;
      end
   endgenerate
endmodule


