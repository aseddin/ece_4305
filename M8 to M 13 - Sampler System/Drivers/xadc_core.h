/*****************************************************************//**
 * @file xadc_core.h
 *
 * @brief retrieve data from MMIO XADC core
 *
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

#ifndef _XADC_CORE_H_INCLUDED
#define _XADC_CORE_H_INCLUDED

#include "chu_init.h"

/**
 * adsr core driver:
 * - retrieve data from 6 xadc channels
 */
class XadcCore {
public:
   /**
    * register map
    */
   enum {
      ADC_0_REG = 0,  /**< 16-bit data from Nexys 4 adc input #0 */
      TMP_REG   = 4,  /**< FPGA internal temperature */
      VCC_REG   = 5,  /**< FPGA internal core voltage */
   };

   /**
    * constructor.
    */
   XadcCore(uint32_t core_base_addr);
   ~XadcCore(); // not used

   /**
    * retrieve raw xadc data
    *
    * @param n adc input source (0 to 5)
    * @return raw 16-bit data
    * @note channels 4/5 are FPGA internal temp/vcc reading
    * @note only 12 MSBs is used for adc data
    */
   uint16_t read_raw(int n);

   /**
    * retrieve adc voltage
    *
    * @param n adc input source (0 to 3)
    * @return voltage between 0.0 and 1.0
    * @note input 4/5 (temp/vcc) needs to be further processed
    */
   double read_adc_in(int n);

   /**
    * retrieve FPGA internal vcc
    * @return FPGA core Vcc (about 1.0V)
    * @note vcc=3*(adc reading)
    */
   double read_fpga_vcc();

   /**
    * retrieve FPGA internal temperature
    * @return FPGA core temperature in Celsius
    * @note see Xilinx ug480
    */
   double read_fpga_temp();

private:
   /* variable to keep track of current status */
   uint32_t base_addr;
}
;

#endif  // _XADC_CORE_H_INCLUDED