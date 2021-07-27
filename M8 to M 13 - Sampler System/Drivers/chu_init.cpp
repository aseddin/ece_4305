/*****************************************************************//**
 * @file chu_init.cpp
 *
 * @brief implementation of basic timing/serial functions
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/




#include "chu_init.h"

/**********************************************************************
 * basic uart and timer functions
 *  - define basic timing function
 *  - define the basic char stream serial port "uart"
 *  - obtain BRIDGE_BASE from chu_io_map.h
 *  - time slot is 0
 *  - uart slot is 1
 *********************************************************************/

TimerCore _sys_timer(get_slot_addr(BRIDGE_BASE, TIMER_SLOT));
UartCore uart(get_slot_addr(BRIDGE_BASE, UART_SLOT));

// current system time in microsecond
unsigned long now_us() {
   return ((unsigned long) _sys_timer.read_time());
}

// current system time in ms
unsigned long now_ms() {
   return ((unsigned long) _sys_timer.read_time() / 1000);
}

// idle for t microseconds
void sleep_us(unsigned long int t) {
   _sys_timer.sleep(uint64_t(t));
}

// idle for t ms
void sleep_ms(unsigned long int t) {
   _sys_timer.sleep(uint64_t(1000 * t));
}

// debug asserted
// uart print a 1-line message: msg + 2 numbers in dec/hex format
void debug_on(const char *str, int n1, int n2) {
   uart.disp("debug: ");
   uart.disp(str);
   uart.disp(n1);
   uart.disp("(0x");
   uart.disp(n1, 16);
   uart.disp(") / ");
   uart.disp(n2);
   uart.disp("(0x");
   uart.disp(n2, 16);
   uart.disp(") \n\r");
}

void debug_off() {
}

