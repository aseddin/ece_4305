/*======================================================================
-- Description: synchronization for VGA 
-- Design:
--   * generate horizontal sync and vertical sync of VGA
--   * an FSM sychronizes the beginning of scan with input frame data  
--====================================================================*/

module vga_sync 
   #(parameter CD= 12)    // color depth
   (
    input  logic clk, reset,
    // stream input
    input  logic[CD:0] vga_si_data,  // color+start
    input  logic vga_si_valid,
    output logic vga_si_ready,
    // to vga monitor
    output logic hsync, vsync,
    output logic[CD-1:0] rgb
   );

   // localparam declaration
   // vga 640-by-480 sync parameters
   localparam HD = 640;  // horizontal display area
   localparam HF = 16;   // h. front porch
   localparam HB = 48;   // h. back porch
   localparam HR = 96;   // h. retrace
   localparam HT = HD+HF+HB+HR; // horizontal total (800)
   localparam VD = 480;  // vertical display area
   localparam VF = 10;   // v. front porch
   localparam VB = 33;   // v. back porch
   localparam VR = 2;    // v. retrace
   localparam VT = VD+VF+VB+VR; // vertical total (525)
   // fsm state type 
   typedef enum {frame_sync, disp} state_type;
   // signal declaration
   state_type state_reg, state_next;
   logic vga_st_in_start;
   logic [CD-1:0] vga_st_in_color;
   logic[10:0] x, y;
   logic hsync_i, vsync_i, video_on_i;
   logic scan_end;
   logic vsync_reg, hsync_reg;
   logic [CD-1:0] rgb_reg;
   logic vga_si_ready_i;
   
   // body
   assign vga_st_in_start = vga_si_data[0];
   assign vga_st_in_color = vga_si_data[CD:1];
   //******************************************************************
   // instantiate frame counter
   //******************************************************************
   frame_counter #(.HMAX(HT), .VMAX(VT)) counter_unit
      (.clk(clk), .reset(reset), 
       .sync_clr(0), .hcount(x), .vcount(y), .inc(1), 
       .frame_start(), .frame_end(scan_end));
   //******************************************************************
   // horizontal and vertical sync 
   //******************************************************************
   // horizontal sync decoding
   assign hsync_i = ((x>=(HD+HF)) && (x<=(HD+HF+HR-1))) ? 0 : 1;
   // vertical sync decoding
   assign vsync_i = ((y>=(VD+VF)) && (y<=(VD+VF+VR-1))) ? 0 : 1;
   // display on/off
   assign video_on_i = ((x < HD) && (y < VD)) ? 1: 0;
   //******************************************************************
   // buffered output to vga monitor
   //******************************************************************
   always_ff @(posedge clk) begin
      vsync_reg <= vsync_i;
      hsync_reg <= hsync_i;
      if (video_on_i)
         rgb_reg <= vga_st_in_color;
      else
         rgb_reg <= 0;    // black when display off 
   end
   //******************************************************************
   // FSM to synchronize data for each frame 
   //******************************************************************
   // state register
    always_ff @(posedge clk, posedge reset)
       if (reset)
          state_reg <= frame_sync;
       else
          state_reg <= state_next;
   // next-state/output logic
   always_comb
   begin
      state_next = state_reg; // default next state: the same
      vga_si_ready_i = 1'b0;       // default output: 0
      case (state_reg)
         frame_sync: begin
            // wait for end of current scan (end of v/h retrace)
            if (scan_end) begin
               if (vga_st_in_start)
                  state_next = disp;
               else
                  state_next = frame_sync;
            end      
            // flush out partial frame fragment 
            // (due to corruption or incorrectly formed long packet)  
            if (~vga_st_in_start)
               vga_si_ready_i = 1'b1;
         end      
         default: begin  // disp state
            // resync when reaching end of the displayable data  
            if ((x==HD-1) && (y==VD-1)) 
               state_next = frame_sync;
            if (video_on_i)
               vga_si_ready_i = 1'b1;
         end      
      endcase
   end
   // output 
   assign hsync = hsync_reg;
   assign vsync = vsync_reg;
   assign rgb = rgb_reg;
   assign vga_si_ready = vga_si_ready_i;   
endmodule
