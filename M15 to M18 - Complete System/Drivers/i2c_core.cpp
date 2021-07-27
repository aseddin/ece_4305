/*****************************************************************//**
 * @file i2c_core.cpp
 *
 * @brief implementation of I2cCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "i2c_core.h"

/* methods */
I2cCore::I2cCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
   set_freq(100000);  // default 100K Hz
}
I2cCore::~I2cCore() {
}                  // not used

void I2cCore::set_freq(int freq) {
   uint32_t dvsr;

   // 25% of i2c period = (1/freq)/4; sys clock period = 1/f_sys
   // dvsr = # sys clocks =  ((1/freq)/4)/(1/f_sys) = f_sys/freq/4
   dvsr = (uint32_t) (SYS_CLK_FREQ * 1000000 / freq / 4);
   io_write(base_addr, DVSR_REG, dvsr);
}

int I2cCore::ready() {
   return ((int) (io_read(base_addr,RD_REG) >> 8) & 0x01);
}

void I2cCore::start() {
   while (!ready()) {
   }
   io_write(base_addr, WR_REG, I2C_START_CMD);
}

void I2cCore::restart() {
   while (!ready()) {
   }
   io_write(base_addr, WR_REG, I2C_RESTART_CMD);
}

void I2cCore::stop() {
   while (!ready()) {
   }
   io_write(base_addr, WR_REG, I2C_STOP_CMD);
}

int I2cCore::write_byte(uint8_t data) {
   int ack, acc_data;

   acc_data = data | I2C_WR_CMD;
   while (!ready()) {
   }
   io_write(base_addr, WR_REG, acc_data);
   while (!ready()) {
   }
   ack = (io_read(base_addr, RD_REG) & 0x0200) >> 9;
   if (ack == 0)
      return (0);
   else
      // slave fails to ack
      return (-1);
}

//last: last byte in read cycle (0:no; 1:yes)
//      I2C master generate NACK if LSB of last is 1
int I2cCore::read_byte(int last) {
   int acc_data;

   acc_data = last | I2C_RD_CMD;
   while (!ready()) {
   }
   io_write(base_addr, WR_REG, acc_data);
   while (!ready()) {
   }
   return (io_read(base_addr, RD_REG) & 0x00ff);
}


int I2cCore::read_transaction(uint8_t dev, uint8_t *bytes, int num,
      int rstart) {
   uint8_t dev_byte;
   int ack1;
   int i;

   dev_byte = (dev << 1) | 0x01;   // LSB=1 for I2c read
   start();
   ack1 = write_byte(dev_byte);    // send device id/read
   for (i = 0; i < (num - 1); i++) {
      *bytes = read_byte(0);
      bytes++;
   }
   *bytes = read_byte(1);   // last byte in read cycle
   if (rstart == 1) {
      restart();
   } else {
      stop();
   }
   return (ack1);
}

int I2cCore::write_transaction(uint8_t dev, uint8_t *bytes, int num,
      int rstart) {
   uint8_t dev_byte;
   int ack1, ack;
   int i;

   dev_byte = (dev << 1);   // LSB=0 for I2c write
   start();
   ack = write_byte(dev_byte);  // send device id/write
   for (i = 0; i < num; i++) {
      ack1 = write_byte(*bytes);
      ack = ack + ack1;
      bytes++;
   }
   if (rstart == 1) {
      restart();
   } else {
      stop();
   }
   return (ack);
}
