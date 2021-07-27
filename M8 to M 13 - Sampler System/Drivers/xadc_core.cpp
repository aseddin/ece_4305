/*****************************************************************//**
 * @file xadc_core.cpp
 *
 * @brief implementation of XadcCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "xadc_core.h"

XadcCore::XadcCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
}

XadcCore::~XadcCore() {
}

uint16_t XadcCore::read_raw(int n) {
   uint16_t rd_data;

   rd_data = (uint16_t) io_read(base_addr, n) & 0x0000ffff;
   return (rd_data);
}

double XadcCore::read_adc_in(int n) {
   uint16_t raw;
   raw = read_raw(n) >> 4;
   return ((double) raw / 4096.0);
}

// input source 5 is connected to vcc reading
double XadcCore::read_fpga_vcc() {
   return (read_adc_in(VCC_REG) * 3.0);
}

// input source 4 is connected to temperature reading
double XadcCore::read_fpga_temp() {
   return (read_adc_in(TMP_REG) * 503.975 - 273.15);
}
