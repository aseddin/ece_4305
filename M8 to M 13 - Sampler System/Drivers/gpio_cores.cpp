/*****************************************************************//**
 * @file gpio_core.cpp
 *
 * @brief implementation of various i/o related classes
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "gpio_cores.h"

/**********************************************************************
 * GpiCore
 **********************************************************************/
GpiCore::GpiCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
}
GpiCore::~GpiCore() {
}

uint32_t GpiCore::read() {
   return (io_read(base_addr, DATA_REG));
}

int GpiCore::read(int bit_pos) {
   uint32_t rd_data = io_read(base_addr, DATA_REG);
   return ((int) bit_read(rd_data, bit_pos));
}

/**********************************************************************
 * DebounceCore
 **********************************************************************/
DebounceCore::DebounceCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
}
DebounceCore::~DebounceCore() {
}

uint32_t DebounceCore::read() {
   return (io_read(base_addr, NORMAL_DATA_REG));
}

int DebounceCore::read(int bit_pos) {
   uint32_t rd_data = io_read(base_addr, NORMAL_DATA_REG);
   return ((int) bit_read(rd_data, bit_pos));
}

uint32_t DebounceCore::read_db() {
   return (io_read(base_addr, DB_DATA_REG));
}

int DebounceCore::read_db(int bit_pos) {
   uint32_t rd_data = io_read(base_addr, DB_DATA_REG);
   return ((int) bit_read(rd_data, bit_pos));
}

/**********************************************************************
 * GpoCore
 **********************************************************************/
GpoCore::GpoCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
   wr_data = 0;
}

GpoCore::~GpoCore() {
}

void GpoCore::write(uint32_t data) {
   wr_data = data;
   io_write(base_addr, DATA_REG, wr_data);
}

void GpoCore::write(int bit_value, int bit_pos) {
   bit_write(wr_data, bit_pos, bit_value);
   io_write(base_addr, DATA_REG, wr_data);
}

/**********************************************************************
 * PwmCore
 **********************************************************************/
PwmCore::PwmCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
   set_freq(1000);
}

PwmCore::~PwmCore() {
}

void PwmCore::set_freq(int freq) {
   uint32_t dvsr;
   dvsr = (uint32_t) SYS_CLK_FREQ * 1000000 / MAX / freq;
   io_write(base_addr, DVSR_REG, dvsr);
}

void PwmCore::set_duty(int duty, int channel) {
   uint32_t d;

   if (duty > MAX) {
      d = MAX;
   } else {
      d = duty;
   }
   io_write(base_addr, DUTY_REG_BASE + channel, d);
}

void PwmCore::set_duty(double f, int channel) {
   int duty;
   duty = (int) (f * MAX);
   debug("set_duty_f: ", f, duty);
   set_duty(duty, channel);
}

