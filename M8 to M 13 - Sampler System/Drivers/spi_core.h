/*****************************************************************//**
 * @file spi_core.h
 *
 * @brief control and transfer data via MMIO spi core
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

#ifndef _SPI_CORE_H_INCLUDED
#define _SPI_CORE_H_INCLUDED

#include "chu_init.h"

/**
 *  spi core driver:
 *  - set up and transfer data via spi master
 *
 *  - multiple slave SPI devices can be connected to the master
 *  - the main program must coordinate the access
 *    (can use a "in_use" variable for access control)
 *
 */
class SpiCore {
public:
   /**
    * register map
    *
    * ctrl register fields:
    *   bits 15-0: dvsr;
    *   bit  16: cpol;
    *   bit  17: cpha;
    *   bits 27-24: ss3, ..., ss0
    *
    */
   enum {
      RD_DATA_REG = 0,    /**< 8-bit read data register */
      SS_REG = 1,         /**< 1-bit status register */
      WRITE_DATA_REG = 2, /**< 8-bit write data register */
      CTRL_REG = 3        /**< control register (ss/cpha/cpol/dvsr) */
   };
   /**
    * Field masks
    *
    */
   enum {
      READY_FIELD = 0x00000100, /**< bit 8 of rd_data_reg; ready bit */
      RX_DATA_FIELD = 0x000000ff /**< bits 7..0 rd_data_reg; read data */
   };
   /**
    * Constructor.
    *
    *@note set default to mode 0, 400K Hz
    *
    */
   SpiCore(uint32_t core_base_addr);
   ~SpiCore(); // not used

   /**
    * spi core is ready for transfer
    *
    * @return 1: if ready; 0: otherwise
    */
   int ready();

   /**
    * set spi bus clock frequency
    *
    * @param freq frequency
    */
   void set_freq(int freq);

   /**
    * set spi mode
    *
    * @param icpol spi clock polarity (0 or 1)
    * @param icpha spi clock phase (0 or 1)
    */
   void set_mode(int icpol, int icpha);

   /**
    * write ss_n register
    *
    * @param data ss_n signals (set one device active)
    *
    * @note: ss_n is active low
    *
    */
   void write_ss_n(uint32_t data);

   /**
    * write an ss_n bit at a specific position
    *
    * @param bit_value value (0 or 1)
    * @param bit_pos bit position
    * @note ss_n is active low
    *
    */
   void write_ss_n(int bit_value, int bit_pos);

   /**
    * assert slave select (ss_n)
    *
    * @param n the device #
    * @note ss_n is active low
    *
    */
   void assert_ss(int n);

   /**
    * de-assert slave select (ss_n)
    *
    * @param n the device #
    *
    */
   void deassert_ss(int n);

   /**
    * shift out write data and shift in read data
    *
    *@param wr_data 8-bit write data (to slave)
    *@return 8-bit read data (from slave)
    *
    *@note a transfer performs read/write at the same time.
    *@note a "dummy" write data should be used if only read is needed.
    *
    */
   uint8_t transfer(uint8_t wr_data);

private:
   /* variable to keep track of current status */
   uint32_t base_addr;
   uint32_t ss_n_data;
   uint16_t dvsr;
   int cpol;
   int cpha;
}
;

#endif  // _SPI_CORE_H_INCLUDED
