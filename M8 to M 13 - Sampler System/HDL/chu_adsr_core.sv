// ADSR output 31-bit envelop 
//   16 bits: max 6 ms attack time; 31 bits: 200 sec attack time
//   use 31 bits to avoid overflow problem in C
// AW:use 31 bits 
//    * simplify C code (no need to use unsigned int)
//    * simplify VHDL simulation (Xinlin ISIM use 32-bit integer)
//    * can accomodate 20 sec for 100 MHz clock 
// 

module chu_adsr_core
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external port    
    output logic [15:0] adsr_env
   );

   // signal declaration
   logic [31:0] atk_step_reg, dcy_step_reg, sus_level_reg, rel_step_reg;
   logic [31:0] sus_time_reg;
   logic [25:0] focw, pha;
   logic [15:0] env_reg;
   logic [15:0] env;
   logic [2:0] ctrl_reg;
   logic idle;
   logic wr_en, wr_atk, wr_dcy, wr_sus_level, wr_rel, wr_start, wr_sus_time;
   logic [15:0] pcm; 
   // instantiate adsr
   adsr adsr_unit (
    .clk(clk), .reset(reset), 
    .start(wr_start), .atk_step(atk_step_reg),
    .dcy_step (dcy_step_reg),
    .sus_level(sus_level_reg),
    .sus_time (sus_time_reg),
    .rel_step (rel_step_reg),
    .env(adsr_env),
    .adsr_idle(idle)
   );
       
   assign pcm_out = pcm;
   // registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         atk_step_reg <= 0;
         dcy_step_reg <= 0;
         sus_level_reg <= 0;
         rel_step_reg <= 0;
         sus_time_reg <= 0;
      end 
      else begin
         if (wr_atk)
            atk_step_reg <= wr_data;
         if (wr_dcy)
            dcy_step_reg <= wr_data;
         if (wr_sus_level)
            sus_level_reg <= wr_data;
         if (wr_rel)
            rel_step_reg <= wr_data;
         if (wr_sus_time)
            sus_time_reg <= wr_data;
     end
   // decoding
   assign wr_en = write & cs;
   assign wr_start     = (addr[2:0]==3'b000) & wr_en;
   assign wr_atk       = (addr[2:0]==3'b001) & wr_en;
   assign wr_dcy       = (addr[2:0]==3'b010) & wr_en;
   assign wr_sus_time  = (addr[2:0]==3'b011) & wr_en;
   assign wr_rel       = (addr[2:0]==3'b100) & wr_en;
   assign wr_sus_level = (addr[2:0]==3'b101) & wr_en;
   // read out
   assign rd_data = {31'b0, idle};
endmodule     

