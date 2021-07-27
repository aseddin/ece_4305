/*****************************************************************//**
 * @file timer_core.h
 *
 * @brief Control and retrieve clock count from MMIO timer core
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#ifndef _TIMER_H_INCLUDED
#define _TIMER_H_INCLUDED

#include "chu_io_rw.h"
#include "chu_io_map.h"      /* to obtain system clock rate  */

/**
 * timer core driver:
 *  - control and retrieve clock count from MMIO timer core.
 *
 */
class TimerCore {
public:
   /**
    * register map
    *
    */
   enum {
      COUNTER_LOWER_REG = 0, /**< lower 32 bits of counter */
      COUNTER_UPPER_REG = 1, /**< upper 16 bits of counter */
      CTRL_REG = 2           /**< control register */
   };
   /**
   * field masks
   *
   */
   enum {
      GO_FIELD = 0x00000001, /**< bit 0 of ctrl_reg; enable bit  */
      CLR_FIELD = 0x00000002 /**< bit 1 of ctrl_reg; clear bit */
   };
   /* methods */
   /**
    * constructor.
    *
    */
   TimerCore(uint32_t core_base_addr);
   ~TimerCore();                  // not used

   /**
    * pause timer counter
    *
    */
   void pause();

   /**
    * enable timer counter
    *
    */
   void go();

   /**
    * clear timing counter to 0
    *
    * note: write clear bit but no effect on ctrl;
    * timer will pause/go as before
    *
    */
   void clear();

   /**
    * read current timing counter value (# clocks elapsed from last clear)
    *
    */
   uint64_t read_tick();

   /**
    * read current time (microseconds elapsed from last clear)
    *
    * @note time is derived from SYS_CLK_FREQ in chu_io_map.h
    *
    */
   uint64_t read_time();

   /**
    * idle (busy waiting) for us microsecond
    *
    * @param us idle time in micro second
    * @note will block the program execution
    *
    */
   void sleep(uint64_t us);

private:
   uint32_t base_addr;
   uint32_t ctrl;    // current state of control register
};

#endif  // _TIMER_H_INCLUDED
