/*****************************************************************//**
 * @file chu_io_rw.h
 *
 * @brief Define io rd/wr and address calculation macros
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

#ifndef _CHU_IO_RW_H_INCLUDED
#define _CHU_IO_RW_H_INCLUDED

// library
#include <inttypes.h>    // to use unitN_t type
#ifdef __cplusplus
extern "C" {
#endif

/**********************************************************************
 * generic low-level read and write access
 *  - offset: 32-bit word offset relative to base
 *  - 4*offset used for byte address
 *  - must bypass data cache for I/O access
 *  - may be replaced with vendor provided macros
 *   (if _VENDOR_IO_ACCESS_USED is defined)
 *********************************************************************/
#ifndef _VENDOR_IO_ACCESS_USED

/**
 * read an io register.
 * @param base_addr base address of an io core
 * @param offset register word offset.
 * @return 32-bit data of the register
 * @note macro calculates the byte address of the register and then read
 */
#define io_read(base_addr, offset) \
   (*(volatile uint32_t *)((base_addr) + 4*(offset)))

/**
 * write an io register
 * @param base_addr base address of an io core
 * @param offset register word offset
 * @param data 32-bit data
 */
#define io_write(base_addr, offset, data) \
   (*(volatile uint32_t *)((base_addr) + 4*(offset)) = (data))

#endif  // _VENDOR_IO_ACCESS_USED
/**
 * calculate base address of a memory mapped io slot.
 * @param base base-address of FPro system.
 * @param slot designated io slot number.
 * @return base address of the slot
 * @note that there are 32 words per slot.
 */
#define get_slot_addr(base, slot) \
		((uint32_t)((base) + (slot)*32*4))

/**
 * Calculate base address of a video system slot.
 * @param base base-address of FPro system.
 * @param sprite designated video sprite slot number.
 * @return base address of the sprite
 * @note there are 2^14 words per slot.
 *      0x008000000 is the memory space for video system
 */
#define get_sprite_addr(base, sprite) \
		((uint32_t)((base) + 0x00800000 + (sprite)*16384*4))
#ifdef __cplusplus
} // extern "C"
#endif

#endif /* _CHU_IO_RW_H_INCLUDED */
