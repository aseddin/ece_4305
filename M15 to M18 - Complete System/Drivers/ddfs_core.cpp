/*****************************************************************//**
 * @file ddfs_core.cpp
 *
 * @brief implementation of DdfsCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "ddfs_core.h"

DdfsCore::DdfsCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
   init();
}
;
DdfsCore::~DdfsCore() {
}
// not used

void DdfsCore::init() {
   // select processor bus
   set_env_source(0);
   set_fow_source(0);
   set_pha_source(0);
   // set note C
   set_carrier_freq(262);
   set_offset_freq(0);
   set_phase_degree(0);
   set_env(1.0);
}

void DdfsCore::set_carrier_freq(int freq) {
   uint32_t fcw, p2n;
   float tmp;

   p2n = 1 << PHA_WIDTH;  //2^PHA_WIDTH
   tmp = ((float) p2n) / float(SYS_CLK_FREQ * 1000000);
   fcw = uint32_t(freq * tmp);
   io_write(base_addr, FCW_REG, fcw);
}

void DdfsCore::set_offset_freq(int freq) {
   uint32_t fow, p2n;
   float tmp;

   p2n = 1 << PHA_WIDTH;  //2^PHA_WIDTH
   tmp = ((float) p2n) / float(SYS_CLK_FREQ * 1000000);
   fow = uint32_t(freq * tmp);
   io_write(base_addr, FOW_REG, fow);
}

void DdfsCore::set_phase_degree(int phase) {
   uint32_t pha;

   pha = (SYS_CLK_FREQ * 1000000) * phase / 360;
   io_write(base_addr, PHA_REG, pha);
}

void DdfsCore::set_env(float env) {
   // convert floating point to fixed-point Q2.14 format
   int32_t q214;
   float max_amp;

   max_amp = (float) (0x4000);   // 2^15
   q214 = (int32_t) (env * max_amp);
   io_write(base_addr, ENV_REG, q214 & 0x0000ffff);
}

void DdfsCore::set_fow_source(int channel) {
   int ch = 0;

   if (channel == 1)
      ch = 1;
   bit_write(ch_select_reg, 1, ch);
   io_write(base_addr, SRC_SEL_REG, ch_select_reg);
}

void DdfsCore::set_env_source(int channel) {
   int ch = 0;

   if (channel == 1)
      ch = 1;
   bit_write(ch_select_reg, 0, ch);
   io_write(base_addr, SRC_SEL_REG, ch_select_reg);
}

void DdfsCore::set_pha_source(int channel) {
   int ch = 0;

   if (channel == 1)
      ch = 1;
   bit_write(ch_select_reg, 2, ch);
   io_write(base_addr, SRC_SEL_REG, ch_select_reg);
}

int16_t DdfsCore::read_pcm() {
   uint32_t word;

   word = io_read(base_addr, 0);
   return ((int16_t) word);
}


