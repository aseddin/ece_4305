/*****************************************************************//**
 * @file chu_init.h
 *
 * @brief define bit-manipulation macros and timing/serial functions
 *
 * Description:
 *  - create a "_sys_timer" instance  of a timer core in slot 0
 *  - define basic timing function
 *  - define the basic char stream serial port "uart"
 *  - _sys_timer used for system time and sleep functions
 *  - _sys_timer is in .c file and not visible
 *  - create a "uart" instance of a uart core in slot 1
 *  - "uart" is visible by external code
 *  - "uart" can be used as the default char stream port
 *  - timer core and uart core must be instantiated in slots 0 and 1
 *  - debug() macro print a message when _DEBUG defined
 *
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

/**********************************************************************
 * basic uart and timer functions
 *  - obtain BRIDGE_BASE from chu_io_map.h

 *********************************************************************/

#ifndef _CHU_INIT_H_INCLUDED
#define _CHU_INIT_H_INCLUDED

// library
#include "chu_io_rw.h"
#include "chu_io_map.h"
#include "timer_core.h"
#include "uart_core.h"

//  make uart visible by other code
extern UartCore uart;

#ifdef __cplusplus
extern "C" {
#endif

#define TIMER_SLOT 0
#define UART_SLOT 1

/**
 * Current system "up time" in microsecond.
 */
unsigned long now_us();

/**
 * Current system "up time" in millisecond.
 */
unsigned long now_ms();

/**
 * idle for t microsecond.
 * @param t idle time
 */
void sleep_us(unsigned long int t);

/**
 * idle for t millisecond.
 * @param t idle time
 */
void sleep_ms(unsigned long int t);


/**********************************************************************
 * debug(): function to facilitate debugging
 *  - send a one0line message via "uart"
 *  - controlled by _DEBUG
 *  - _DEBUG must be defined in individual file
 *  - replaced with debug_off() when _DEBUG not defined
 *  - replaced with debug_on() when _DEBUG defined
 *  - debug_on()print a 1-line message (a string plus 2 numbers)
 *
 *********************************************************************/

/**
 * dummy function.
 @note substitute debug() when _DEBUG is not defined
 */
void debug_off();

/**
 * print a one line message (string plus 2 numbers).
 * @param str a string
 * @param n1 first number
 * @param n2 first number
 * @note substitute debug() when _DEBUG is defined
 */
void debug_on(const char *str, int n1, int n2);

#ifndef _DEBUG
#define debug(str, n1, n2) debug_off()
#endif // not _DEBUG#ifdef _DEBUG
#define debug(str, n1, n2) debug_on((str), (n1), (n2))
#endif // not _DEBUG#ifdef __cplusplus
} // extern "C"
#endif

/**********************************************************************
 * low-level bit-manipulation macros
 * @param n bit position
 *********************************************************************/
#define bit_set(data, n) ((data) |= (1UL << (n)))
#define bit_clear(data, n) ((data) &= ~(1UL << (n)))
#define bit_toggle(data, n) ((data) ^= (1UL << (n)))
#define bit_read(data, n) (((data) >> (n)) & 0x01)
#define bit_write(data, n, bitvalue) (bitvalue ? bit_set((data), n) : bit_clear((data), n))
#define bit(n) (1UL << (n))

#endif  // _CHU_INIT_H_INCLUDED