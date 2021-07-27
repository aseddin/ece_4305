module frame_palette_9 (
    input  logic [8:0] color_in,
    output logic [11:0] color_out
   );

   // signal delaration
   logic [2:0] r_in, g_in, b_in;
   logic [3:0] r_out, g_out, b_out;
   
   // body 
   assign r_in = color_in[8:6];
   assign g_in = color_in[5:3];
   assign b_in = color_in[2:0];
   assign r_out = {r_in, r_in[2]};
   assign g_out = {g_in, g_in[2]};
   assign b_out = {b_in, b_in[2]};
   assign color_out = {r_out, g_out, b_out};
endmodule

