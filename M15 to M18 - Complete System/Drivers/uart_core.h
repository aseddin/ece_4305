/*****************************************************************//**
 * @file uart_core.h
 *
 * @brief Access MMIO timer core and
 *        display number/sting on a serial console
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#ifndef _UART_CORE_H_INCLUDED
#define _UART_CORE_H_INCLUDED

#include "chu_io_rw.h"
#include "chu_io_map.h"  // to use SYS_CLK_FREQ
/**
 * uart core driver
 * - transmit/receive data via MMIO uart core.
 * - display (print) number and string on serial console
 *
 */
class UartCore {
   /**
    * register map
    *
    */
   enum {
      RD_DATA_REG = 0,   /**< rx data/status register */
      DVSR_REG = 1,      /**< baud rate divisor register */
      WR_DATA_REG = 2,   /**< wr data register */
      RM_RD_DATA_REG = 3 /**< remove read data offset */
   };
  /**
   * mask fields
   *
   */
   enum {
      TX_FULL_FIELD = 0x00000200, /**< bit 9 of rd_data_reg; full bit  */
      RX_EMPT_FIELD = 0x00000100, /**< bit 10 of rd_data_reg; empty bit */
      RX_DATA_FIELD = 0x000000ff  /**< bits 7..0 rd_data_reg; read data */
   };
public:
   /* methods */
   /**
    * constructor.
    *
    * @note set the default rate to 9600 baud
    */
   UartCore(uint32_t core_base_addr);
   ~UartCore();

   /**
    * set baud rate
    *
    * @param baud baud rate
    * @note baud rate = sys_clk_freq/16/(dvsr+1)
    */
   void set_baud_rate(int baud);

   /**
    * check whether uart receiver fifo is empty
    *
    * @return 1: if empty; 0: otherwise
    *
    */
   int rx_fifo_empty();

   /**
    * check whether uart transmitter fifo is full
    *
    * @return 1: if full; 0: otherwise
    *
    */
   int tx_fifo_full();

   /**
    * transmit a byte
    *
    * @param byte data byte to be transmitted
    *
    * @note the function "busy waits" if tx fifo is full;
    *       to avoid "blocking" execution, use tx_fifo_full() to check status as needed
    */
   void tx_byte(uint8_t byte);

   /**
    * receive a byte
    *
    * @return -1 if rx fifo empty; byte data other wise
    *
    * @note the function does not "busy wait"
    */
   int rx_byte();

   /**
    * display (print) a char on a serial terminal console
    *
    * @param ch char to be displayed
    *
    */
   void disp(char ch);

   /**
    * display (print) a string on a serial terminal console
    *
    * @param str pointer to the string to be displayed
    *
    */
   void disp(const char *str);

   /**
    * display (print) an integer on a serial terminal console
    *
    * @param n integer to be displayed
    * @param base 2/8/10/16 for binary/octal/decimal/hex format
    * @param len # of digits (length) to be displayed
    *
    * @note padding blank spaces are added if printed digits smaller than len;
    * @note if len=0, # digits determined automatically without blanks
    *
    */
   void disp(int n, int base, int len);

   /**
    * display (print) an integer on a serial terminal console
    *
    * @param n integer to be displayed
    * @param base 2/8/10/16 for binary/octal/decimal/hex format
    * @note # digits determined automatically without blanks
    *       (i.e., len=0)
    *
    */
   void disp(int n, int base);

   /**
    * display (print) an integer on a serial terminal console
    *
    * @param n integer to be displayed
    * @note base 10 used
    * @note # digits determined automatically without blanks
    *       (i.e., len=0)
    *
    */
   void disp(int n);

   /**
    * display (print) a floating-point number on a serial terminal console
    *
    * @param f floating-point number to be displayed
    * @param digit # of digits (length) in fraction portion to be displayed
    * @note base 10 used
    * @note length in integer determined automatically
    *
    */
   void disp(double f, int digit);

   /**
    * display (print) a floating-point number on a serial terminal console
    *
    * @param f floating-point number to be displayed
    * @note 3 digits in fraction portion to be displayed
    * @note base 10 used
    * @note length in integer determined automatically
    *
    */
   void disp(double f);

private:
   uint32_t base_addr;
   int baud_rate;
   void disp_str(const char *str);
};

#endif  // _UART_CORE_H_INCLUDED
