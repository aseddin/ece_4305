/*****************************************************************//**
 * @file i2c_core.h
 *
 * @brief access MMIO i2c core
 *
 * Description:
 * - 5 basic commands: start, read, write, stop, restart
 * - i2c transaction can be "assembled" with commands
 *   e.g., start, write, write, stop
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

#ifndef _I2C_CORE_H_INCLUDED
#define _I2C_CORE_H_INCLUDED

#include "chu_init.h"

/**
 * i2c core driver
 * - access MMIO i2c core
 * - 5 basic i2c commands: start, read, write, stop, restart
 * - i2c transaction can be "assembled" with commands;
 *   e.g., start, write, write, stop
 *
 */
class I2cCore {
public:
   /**
    * register map
    *
    * read data reg in read operation:
    * bits 7-0: data
    * bit 8: ready
    * bit 9: acknowledge
    *
    * write data reg in write operation:
    * bits 7-0: data
    * bits 10-8: command

    */
   enum {
	  RD_REG = 0,    /**< read data/status register */
      DVSR_REG = 1,
      WR_REG = 2   /**< write data/command register */
   };
   /**
    * symbolic commands
    *
    */
   enum {
      I2C_START_CMD = 0x00 << 8,  /**< start command */
      I2C_WR_CMD = 0x01 << 8,     /**< write command */
      I2C_RD_CMD = 0x02 << 8,     /**< read command */
      I2C_STOP_CMD = 0x03 << 8,   /**< stop command */
      I2C_RESTART_CMD = 0x04 << 8 /**< restart command */
   };
   /* methods */
   /**
    * constructor
    *
	* @note set default i2c clock rate to 100K Hz
    */
   I2cCore(uint32_t core_base_addr);
   ~I2cCore();                  // not used

   /**
    * set i2c clock (sclk) frequency
    *
    * @param freq i2c clock frequency
    *
    */
   void set_freq(int freq);

   /**
    * indicate whether i2c core is ready to take a command
    *
    */
   int ready();

   /**
    * issue a start command
    *
    */
   void start();

   /**
    * issue a restart command
    *
    */
   void restart();

   /**
    * issue a stop command
    *
    */
   void stop();

   /**
    * issue a write command
    *
    * @param data 8-bit data
    * @return device ack status (0: ok; -1: failed)
    *
    */
   int write_byte(uint8_t data);

   /**
    * issue a read command
    *
    * @param last indicates the last byte in read cycle (0: no; 1:yes)
    * @return 8-bit read data
    *
    * @note last byte in read cycle forces i2c master generating NACK
    *
    */
   int read_byte(int last);


   /**
    * perform a read transaction
    *
    * @param dev device id
    * @param bytes pointer to read data array
    * @param num number of bytes to be read
    * @param restart 1:issue "restart" command in the end; 0:issue "stop" command
    *
    * @return device ack status (0: ok; -1: # failed ack)
    * @return retrieved data store in bytes array
    *
    * @note command sequence: start, write dev, read, .. read, stop/restart
    *
    */
   int read_transaction(uint8_t dev, uint8_t *bytes, int num,
         int restart);

   /**
    * perform a write transaction
    *
    * @param dev device id
    * @param bytes pointer to write data array
    * @param num number of bytes to be written
    * @param restart 1:issue "restart" command in the end; 0:issue "stop" command
    *
    * @return device ack status (0: ok; negative: # failed acks)
    *
    * @note command sequence: start, write dev, write, .. write, stop/restart
    *
    */
   int write_transaction(uint8_t dev, uint8_t *bytes, int num,
         int restart);

private:
   /* variable to keep track of current status */
   uint32_t base_addr;

};

#endif  //_I2C_CORE_H_INCLUDED
