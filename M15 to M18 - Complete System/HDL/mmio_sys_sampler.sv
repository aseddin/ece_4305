// specifiy I/O core parameters in this level 

`include "chu_io_map.svh"
module mmio_sys_sampler
#(
  parameter N_SW = 8,
            N_LED = 8
)	
(
   input logic clk,
   input logic reset,
   // FPro bus 
   input  logic mmio_cs,
   input  logic mmio_wr,
   input  logic mmio_rd,
   input  logic [20:0] mmio_addr, 
   input  logic [31:0] mmio_wr_data,
   output logic [31:0] mmio_rd_data,
   // switches and LEDs
   input  logic [N_SW-1:0] sw,
   output logic [N_LED-1:0] led,
   // uart
   input  logic rx,
   output logic tx,          
   // 4 analog input pair
   input  logic [3:0] adc_p, adc_n,
   // pwm 
   output logic [7:0] pwm,
   // btn
   input logic [4:0] btn,
   // 8-digit 7-seg LEDs
   output logic [7:0] an,
   output logic [7:0] sseg,
   // spi accelerator
   output logic acl_sclk, acl_mosi,
   input  logic acl_miso,
   output logic acl_ss,
   // i2c temperature sensor  
   output logic tmp_i2c_scl,
   inout  tri tmp_i2c_sda,
   // ps2
   inout  tri ps2d,
   inout  tri ps2c,
   // ddfs square wave output
   output  logic  ddfs_sq_wave,
   // 1-bit dac 
    output logic  pdm 
);

   //declaration
   logic [63:0] mem_rd_array;
   logic [63:0] mem_wr_array;
   logic [63:0] cs_array;
   logic [4:0] reg_addr_array [63:0];
   logic [31:0] rd_data_array [63:0]; 
   logic [31:0] wr_data_array [63:0];
   logic [15:0] adsr_env;

   // body
   // instantiate mmio controller 
   chu_mmio_controller ctrl_unit
   (.clk(clk),
    .reset(reset),
    .mmio_cs(mmio_cs),
    .mmio_wr(mmio_wr),
    .mmio_rd(mmio_rd),
    .mmio_addr(mmio_addr), 
    .mmio_wr_data(mmio_wr_data),
    .mmio_rd_data(mmio_rd_data),
    // slot interface
    .slot_cs_array(cs_array),
    .slot_mem_rd_array(mem_rd_array),
    .slot_mem_wr_array(mem_wr_array),
    .slot_reg_addr_array(reg_addr_array),
    .slot_rd_data_array(rd_data_array), 
    .slot_wr_data_array(wr_data_array)
    );
  
   // slot 0: system timer 
   chu_timer timer_slot0 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S0_SYS_TIMER]),
    .read(mem_rd_array[`S0_SYS_TIMER]),
    .write(mem_wr_array[`S0_SYS_TIMER]),
    .addr(reg_addr_array[`S0_SYS_TIMER]),
    .rd_data(rd_data_array[`S0_SYS_TIMER]),
    .wr_data(wr_data_array[`S0_SYS_TIMER])
    );

   // slot 1: UART 
   chu_uart #(.FIFO_DEPTH_BIT(8))  uart_slot1 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S1_UART1]),
    .read(mem_rd_array[`S1_UART1]),
    .write(mem_wr_array[`S1_UART1]),
    .addr(reg_addr_array[`S1_UART1]),
    .rd_data(rd_data_array[`S1_UART1]),
    .wr_data(wr_data_array[`S1_UART1]), 
    .tx(tx),
    .rx(rx)
    );

   // slot 2: gpo 
   chu_gpo #(.W(N_LED)) gpo_slot2 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S2_LED]),
    .read(mem_rd_array[`S2_LED]),
    .write(mem_wr_array[`S2_LED]),
    .addr(reg_addr_array[`S2_LED]),
    .rd_data(rd_data_array[`S2_LED]),
    .wr_data(wr_data_array[`S2_LED]),
    .dout(led)
    );

   // slot 3: gpi 
   chu_gpi #(.W(N_SW)) gpi_slot3 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S3_SW]),
    .read(mem_rd_array[`S3_SW]),
    .write(mem_wr_array[`S3_SW]),
    .addr(reg_addr_array[`S3_SW]),
    .rd_data(rd_data_array[`S3_SW]),
    .wr_data(wr_data_array[`S3_SW]),
    .din(sw)
    );
    
    // slot 4: reserved for user defined  
   // chu_gpi #(.W(N_SW)) user_slot4 
   // (.clk(clk),
   //  .reset(reset),
   //  .cs(cs_array[`S4_USER]),
   //  .read(mem_rd_array[`S4_USER]),
   //  .write(mem_wr_array[`S4_USER]),
   //  .addr(reg_addr_array[`S4_USER]),
   //  .rd_data(rd_data_array[`S4_USER]),
   //  .wr_data(wr_data_array[`S4_USER]),
   //  .din(sw)
   //  );
   assign rd_data_array[`S4_USER] = 32'h00000000;
   
   // slot 5: xadc 
   chu_xadc_core xadc_slot5 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S5_XDAC]),
    .read(mem_rd_array[`S5_XDAC]),
    .write(mem_wr_array[`S5_XDAC]),
    .addr(reg_addr_array[`S5_XDAC]),
    .rd_data(rd_data_array[`S5_XDAC]),
    .wr_data(wr_data_array[`S5_XDAC]),
    .adc_p(adc_p),
    .adc_n(adc_n)
    );
    
   // slot 6: pwm 
    chu_io_pwm_core #(.W(8), .R(10)) pwm_slot6 //
    (.clk(clk),
     .reset(reset),
     .cs(cs_array[`S6_PWM]),
     .read(mem_rd_array[`S6_PWM]),
     .write(mem_wr_array[`S6_PWM]),
     .addr(reg_addr_array[`S6_PWM]),
     .rd_data(rd_data_array[`S6_PWM]),
     .wr_data(wr_data_array[`S6_PWM]),
     .pwm_out(pwm)
     );
     
    // slot 6: pwm 
     chu_debounce_core #(.W(5), .N(20)) debounce_slot7 //
     (.clk(clk),
      .reset(reset),
      .cs(cs_array[`S7_BTN]),
      .read(mem_rd_array[`S7_BTN]),
      .write(mem_wr_array[`S7_BTN]),
      .addr(reg_addr_array[`S7_BTN]),
      .rd_data(rd_data_array[`S7_BTN]),
      .wr_data(wr_data_array[`S7_BTN]),
      .din(btn)
      );
       
   // slot 8: led mux 
   chu_led_mux_core led_slot8 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S8_SSEG]),
    .read(mem_rd_array[`S8_SSEG]),
    .write(mem_wr_array[`S8_SSEG]),
    .addr(reg_addr_array[`S8_SSEG]),
    .rd_data(rd_data_array[`S8_SSEG]),
    .wr_data(wr_data_array[`S8_SSEG]),
    .sseg(sseg),
    .an(an)
    );
    
   // slot 9: spi 
   chu_spi_core #(.S(1)) spi_slot9 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S9_SPI]),
    .read(mem_rd_array[`S9_SPI]),
    .write(mem_wr_array[`S9_SPI]),
    .addr(reg_addr_array[`S9_SPI]),
    .rd_data(rd_data_array[`S9_SPI]),
    .wr_data(wr_data_array[`S9_SPI]),
    .spi_sclk(acl_sclk),
    .spi_mosi(acl_mosi),
    .spi_miso(acl_miso),
    .spi_ss_n(acl_ss)
    );
    
   // slot 10: i2c 
    chu_i2c_core i2c_slot10 
    (.clk(clk),
     .reset(reset),
     .cs(cs_array[`S10_I2C]),
     .read(mem_rd_array[`S10_I2C]),
     .write(mem_wr_array[`S10_I2C]),
     .addr(reg_addr_array[`S10_I2C]),
     .rd_data(rd_data_array[`S10_I2C]),
     .wr_data(wr_data_array[`S10_I2C]),
     .scl(tmp_i2c_scl),
     .sda(tmp_i2c_sda)
     );
     
   // slot 11: ps2 
    chu_ps2_core #(.W_SIZE(8)) ps2_slot11 
    (.clk(clk),
     .reset(reset),
     .cs(cs_array[`S11_PS2]),
     .read(mem_rd_array[`S11_PS2]),
     .write(mem_wr_array[`S11_PS2]),
     .addr(reg_addr_array[`S11_PS2]),
     .rd_data(rd_data_array[`S11_PS2]),
     .wr_data(wr_data_array[`S11_PS2]),
     .ps2d(ps2d),
     .ps2c(ps2c)
     );
     
   // slot 12: ddfs 
   chu_ddfs_core ddfs_slot12 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S12_DDFS]),
    .read(mem_rd_array[`S12_DDFS]),
    .write(mem_wr_array[`S12_DDFS]),
    .addr(reg_addr_array[`S12_DDFS]),
    .rd_data(rd_data_array[`S12_DDFS]),
    .wr_data(wr_data_array[`S12_DDFS]),
    .focw_ext(26'h0),
    .pha_ext(26'h0),
    .env_ext(adsr_env),
    .pcm_out(),
    .digital_out(ddfs_sq_wave),
    .pdm_out(pdm)
    );
    
   // slot 13: adsr 
   chu_adsr_core adsr_slot13 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S13_ADSR]),
    .read(mem_rd_array[`S13_ADSR]),
    .write(mem_wr_array[`S13_ADSR]),
    .addr(reg_addr_array[`S13_ADSR]),
    .rd_data(rd_data_array[`S13_ADSR]),
    .wr_data(wr_data_array[`S13_ADSR]),
    .adsr_env(adsr_env)
    );

   // assign 0's to all unused slot rd_data signals
   generate
      genvar i;
      for (i=14; i<64; i=i+1) begin
         assign rd_data_array[i] = 32'h0;
      end
   endgenerate
endmodule



