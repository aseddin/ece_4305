/*****************************************************************//**
 * @file spi_core.cpp
 *
 * @brief implementation of SpiCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "spi_core.h"

SpiCore::SpiCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
   // set default spi configuration to be 400K Hz, mode 0
   set_freq(400000);
   set_mode(0, 0);
   //write_ctrl_reg();
   write_ss_n(0xffffffff);  // de-assert all ss_n signals
}
SpiCore::~SpiCore() {
}

int SpiCore::ready() {
   uint32_t rd_word;
   int rdy;

   rd_word = io_read(base_addr, RD_DATA_REG);
   rdy = (int) (rd_word & READY_FIELD) >> 8;
   return (rdy);

}

void SpiCore::set_freq(int freq) {
   uint32_t ctrl_word;

   dvsr = (uint16_t) (SYS_CLK_FREQ * 1000000 / (2 * freq));
   dvsr = dvsr - 1;   // counts 0 to dvsr-1
   ctrl_word = cpha << 17 | cpol << 16 | dvsr;
   io_write(base_addr, CTRL_REG, ctrl_word);

}

void SpiCore::set_mode(int icpol, int icpha) {
   uint32_t ctrl_word;

   cpol = icpol;
   cpha = icpha;
   ctrl_word = cpha << 17 | cpol << 16 | dvsr;
   io_write(base_addr, CTRL_REG, ctrl_word);
}

void SpiCore::write_ss_n(uint32_t data) {
   ss_n_data = data;
   io_write(base_addr, SS_REG, ss_n_data);
}

void SpiCore::write_ss_n(int bit_value, int bit_pos) {
   bit_write(ss_n_data, bit_pos, bit_value);
   io_write(base_addr, SS_REG, ss_n_data);
}

void SpiCore::assert_ss(int n) {
   write_ss_n(0, n);
}

void SpiCore::deassert_ss(int n)  //
      {
   write_ss_n(1, n);
}

/* shift out write data and shift in read data */
uint8_t SpiCore::transfer(uint8_t wr_data) {
   uint32_t rd_data;

   while (!ready()) {
   };
   io_write(base_addr, WRITE_DATA_REG, (uint32_t ) wr_data);
   while (!ready()) {
   };
   rd_data = io_read(base_addr, RD_DATA_REG) & RX_DATA_FIELD;
   return ((uint8_t) rd_data);
}

