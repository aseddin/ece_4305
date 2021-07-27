/*****************************************************************//**
 * @file sseg_core.cpp
 *
 * @brief implementation of SsegCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "sseg_core.h"

SsegCore::SsegCore(uint32_t core_base_addr) {
   // pattern for "HI"; the order in array is reversed in 7-seg display
   // i.e., HI_PTN[0] is the leftmost led
   const uint8_t HI_PTN[]={0xff,0xf9,0x89,0xff,0xff,0xff,0xff,0xff};
   base_addr = core_base_addr;
   write_8ptn((uint8_t*) HI_PTN);
   set_dp(0x02);
}

SsegCore::~SsegCore() {
}
// not used

void SsegCore::write_led() {
   int i, p;
   uint32_t word = 0;

   // pack left 4 patterns into a 32-bit word
   // ptn_buf[0] is the leftmost led
   for (i = 0; i < 4; i++) {
      word = (word << 8) | ptn_buf[3 - i];
   }
   // incorporate decimal points (bit 7 of pattern)
   for (i = 0; i < 4; i++) {
      p = bit_read(dp, i);
      bit_write(word, 7 + 8 * i, p);
   }
   io_write(base_addr, DATA_LOW_REG, word);
   // pack right 4 patterns into a 32-bit word
   for (i = 0; i < 4; i++) {
      word = (word << 8) | ptn_buf[7 - i];
   }
   // incorporate decimal points
   for (i = 0; i < 4; i++) {
      p = bit_read(dp, 4 + i);
      bit_write(word, 7 + 8 * i, p);
   }
   io_write(base_addr, DATA_HIGH_REG, word);
}

void SsegCore::write_8ptn(uint8_t *ptn_array) {
   int i;

   for (i = 0; i < 8; i++) {
      ptn_buf[i] = *ptn_array;
      ptn_array++;
   }
   write_led();
}

void SsegCore::write_1ptn(uint8_t pattern, int pos) {
   ptn_buf[pos] = pattern;
   write_led();
}

// set decimal points,
// bits turn on the corresponding decimal points
void SsegCore::set_dp(uint8_t pt) {
   dp = ~pt;     // active low
   write_led();
}

// convert a hex digit to
uint8_t SsegCore::h2s(int hex) {
   /* active-low hex digit 7-seg patterns (0-9,a-f); MSB assigned to 1 */
   static const uint8_t PTN_TABLE[16] =
     {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, //0-9
      0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e };                       //a-f
   uint8_t ptn;

   if (hex < 16)
      ptn = PTN_TABLE[hex];
   else
      ptn = 0xff;
   return (ptn);
}
