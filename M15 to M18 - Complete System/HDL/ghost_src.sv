module ghost_src 
   #(
    parameter CD = 12,      // color depth
              ADDR = 10,    // number of address bits
              KEY_COLOR =0  // chroma key
   )
   (
    input  logic clk,
    input  logic [10:0] x, y,   // x-and  y-coordinate    
    input  logic [10:0] x0, y0, // origin of sprite 
    input  logic [4:0] ctrl,    // sprite control 
    // sprite ram write 
    input  logic we ,
    input  logic [ADDR-1:0] addr_w,
    input  logic [1:0] pixel_in,
    // pixel output
    output logic [CD-1:0] sprite_rgb
   );
   
   // localparam declaration
   localparam H_SIZE = 16; // horizontal size of sprite
   localparam V_SIZE = 16; // vertical size of sprite
   // signal delaration
   logic signed [11:0] xr, yr;  // relative x/y position
   logic in_region;
   logic [ADDR-1:0] addr_r;
   logic [1:0] sid;             // sprite id   
   logic [1:0] plt_code;        
   logic frame_tick, ani_tick;
   logic [3:0] c_next;        
   logic [3:0] c_reg;        
   logic [1:0] ani_next;        
   logic [1:0] ani_reg;        
   logic [10:0] x_d1_reg;
   logic [CD-1:0]  out_rgb;
   logic [CD-1:0] full_rgb, ghost_rgb;
   logic [CD-1:0] out_rgb_d1_reg;
   logic [1:0] gc_color_sel;        
   logic [1:0] gc_id_sel;        
   logic auto;        
   
   // body 
   assign gc_color_sel = ctrl[4:3];
   assign gc_id_sel = ctrl[1:0];
   assign auto = ctrl[2];

   //******************************************************************
   // sprite RAM
   //******************************************************************
   // instantiate sprite RAM
   ghost_ram_lut #(.ADDR_WIDTH(ADDR), .DATA_WIDTH(2)) ram_unit (
      .clk(clk), .we(we), .addr_w(addr_w), .din(pixel_in),
      .addr_r(addr_r), .dout(plt_code));
   assign addr_r = {sid, yr[3:0], xr[3:0]};
 
   //******************************************************************
   // ghost color control
   //******************************************************************
   // ghost color selection
   always_comb
      case (gc_color_sel)
         2'b00:   ghost_rgb = 12'hf00;  // red 
         2'b01:   ghost_rgb = 12'hf8b;  // pink 
         2'b10:   ghost_rgb = 12'hfa0;  // orange
         default: ghost_rgb = 12'h0ff;  // cyan
      endcase   
   // palette table
   always_comb
      case (plt_code)
         2'b00:   full_rgb = 12'h000;   // chrome key
         2'b01:   full_rgb = 12'h111;   // dark gray 
         2'b10:   full_rgb = ghost_rgb; // ghost body color
         default: full_rgb = 12'hfff;   // white
      endcase   
   //******************************************************************
   // in-region circuit
   //******************************************************************
   // relative coordinate calculation
   assign xr = $signed({1'b0, x}) - $signed({1'b0, x0});
   assign yr = $signed({1'b0, y}) - $signed({1'b0, y0});
   // in-region comparison and multiplexing 
   assign in_region = ((0<= xr) && (xr<H_SIZE) && (0<=yr) && (yr<V_SIZE));
   assign out_rgb = in_region ? full_rgb : KEY_COLOR;
   //******************************************************************
   // animation timing control
   //******************************************************************
   // counters 
   always_ff @(posedge clk) begin
      x_d1_reg <= x;
      c_reg <= c_next;
      ani_reg <= ani_next;
   end
   assign c_next = (frame_tick && c_reg==9) ? 0 :
                   (frame_tick) ? c_reg + 1 :
                    c_reg; 
   assign ani_next = (ani_tick) ? ani_reg + 1 : ani_reg;
   // 60-Hz tick from fram counter 
   assign frame_tick = (x_d1_reg==0) && (x==1) && (y==0);
   // sprite animation id tick 
   assign ani_tick  = frame_tick  && (c_reg==0); 
   // sprite id selection
   assign sid = (auto) ? ani_reg : gc_id_sel;
   //******************************************************************
   // delay line (one clock) 
   //******************************************************************
   // output with a-stage delay line
   always_ff @(posedge clk) 
      out_rgb_d1_reg <= out_rgb;
   assign sprite_rgb = out_rgb_d1_reg;
endmodule
  