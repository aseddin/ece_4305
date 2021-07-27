/*****************************************************************//**
 * @file uart_core.cpp
 *
 * @brief implementation of UartCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "uart_core.h"

UartCore::UartCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
   set_baud_rate(9600);      //default baud rate
}

UartCore::~UartCore() {
}

/* baud rate = sys_clk_freq/16/(dvsr+1) */
void UartCore::set_baud_rate(int baud) {
   uint32_t dvsr;

   dvsr = SYS_CLK_FREQ*1000000 / 16 / baud - 1;
   io_write(base_addr, DVSR_REG, dvsr);
}

int UartCore::rx_fifo_empty() {
   uint32_t rd_word;
   int empty;

   rd_word = io_read(base_addr, RD_DATA_REG);
   empty = (int) (rd_word & RX_EMPT_FIELD) >> 8;
   return (empty);
}

int UartCore::tx_fifo_full() {
   uint32_t rd_word;
   int full;

   rd_word = io_read(base_addr, RD_DATA_REG);
   full = (int) (rd_word & TX_FULL_FIELD) >> 9;
   return (full);
}

void UartCore::tx_byte(uint8_t byte) {
   while (tx_fifo_full()) {
   };  // busy waiting
   io_write(base_addr, WR_DATA_REG, (uint32_t )byte);
}

int UartCore::rx_byte() {
   uint32_t data;

   if (rx_fifo_empty())
      return (-1);
   else {
      data = io_read(base_addr, RD_DATA_REG) & RX_DATA_FIELD;
      io_write(base_addr, RM_RD_DATA_REG, 0); //dummy write to remove data from rx FIFO
      return ((int) data);
   }
}

void UartCore::disp(const char *str) {
   disp_str(str);
}

void UartCore::disp(char ch) {
    tx_byte(ch);
}

void UartCore::disp(int n, int base, int len) {
   char buf[33];         // 32 bit #
   char *str, ch, sign;
   int rem, i;
   unsigned int un;

   /* error check */
   if (base != 2 && base != 8 && base != 16)
      base = 10;
   if (len > 32)
      len = 32;
   /* handle neg decimal # */
   if (base == 10 && n < 0) {
      un = (unsigned) -n;
      sign = '-';
   } else {
      un = (unsigned) n; // interpreted as unsigned for hex/bin conversion
      sign = ' ';
   }
   /* convert # to string */
   str = &buf[33];
   *str = '\0';
   i = 0;
   do {
      str--;
      rem = un % base;
      un = un / base;
      if (rem < 10)
         ch = (char) rem + '0';
      else
         ch = (char) rem - 10 + 'a';
      *str = ch;
      i++;
   } while (un);
   /* attach - sign for neg decimal # */
   if (sign == '-') {
      str--;
      *str = sign;
      i++;
   }
   /* pad with blank */
   while (i < len) {
      str--;
      *str = ' ';
      i++;
   };
   disp_str(str);
}

void UartCore::disp(int n) {
   disp(n, 10, 0);
}

void UartCore::disp(int n, int base) {
   disp(n, base, 0);
}

void UartCore::disp(double f, int digit) {
   double fa, frac; // absolute value of f
   int n, i, i_part;

   fa = f;
   if (f < 0.0) {
      fa = -f;
      disp_str("-");
   }
   // display integer portion
   i_part = (int) fa; // integer part of f
   disp(i_part);
   disp_str(".");
   // display fraction part
   frac = fa - (double) i_part;
   for (n = 0; n < digit; n++) {
      frac = frac * 10.0;
      i = (int) frac;
      disp(i);
      frac = frac - i;
   }
}

void UartCore::disp(double f) {
   disp(f, 3);
}

void UartCore::disp_str(const char *str) {
   while ((uint8_t) *str) {
      tx_byte(*str);
      str++;
   }
}


