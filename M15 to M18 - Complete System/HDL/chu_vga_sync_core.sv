module chu_vga_sync_core 
   #(parameter CD = 12)
   (
    input  logic clk_sys,
    input  logic clk_25M,
    input  logic reset,
    // video slot interface
    input  logic cs,      
    input  logic write,  
    input  logic [13:0] addr,    
    input  logic [31:0] wr_data,
    // 
    input  logic [CD:0] si_data,
    input  logic si_valid,
    output logic si_ready,
    // to vga monitor
    output logic hsync, vsync,
    output logic[CD-1:0] rgb
   );

   // signal delaration
   logic line_so_valid, vga_si_ready;
   logic [CD:0] line_so_data;

   // body
   // instantiate line buffer
   line_buffer #(.CD(CD)) line_unit (
    .reset(reset),
    .clk_stream_in(clk_sys),
    .clk_stream_out(clk_25M),
    .si_data(si_data),
    .si_valid(si_valid),
    .si_ready(si_ready),
    .so_data(line_so_data),
    .so_valid(line_so_valid),
    .so_ready(vga_si_ready)
   );
   // instantiate vga controller   
   vga_sync #(.CD(CD)) sync_unit (
    .clk(clk_25M),
    .reset(reset),
    .vga_si_data(line_so_data),
    .vga_si_valid(line_so_valid),
    .vga_si_ready(vga_si_ready),
    .hsync(hsync),
    .vsync(vsync),
    .rgb(rgb)
   );
endmodule