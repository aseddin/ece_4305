/*****************************************************************//**
 * @file vga_core.h
 *
 * @brief contain classes of video cores
 *
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/
#ifndef _VGA_H_INCLUDED
#define _VGA_H_INCLUDED

#include "chu_init.h"
#include <stdlib.h>

/**********************************************************************
 * General-purpose video core
 *********************************************************************/
/**
 *  General-purpose video core driver
 *
 */
class GpvCore {
public:
   /**
    * register map
    *
    */
   enum {
      BYPASS_REG = 0x2000  /**< bypass control register */
   };
   /* methods */
   GpvCore(uint32_t core_base_addr);
   ~GpvCore();                  // not used

   /**
    * write a 32-bit word to memory module/registers of a video core
    * @param addr offset address within core
    * @param color data to be written
    *
    */
   void wr_mem(int addr, uint32_t color);

   /**
    * enable/disable core bypass
    * @param by 1: bypass current core; 0: not bypass
    *
    */
   void bypass(int by);

private:
   uint32_t base_addr;
};

/**********************************************************************
 * Sprite Core
 *********************************************************************/
/**
 * sprite video core driver
 *
 * video subsystem HDL parameter:
 *  - CHROMA_KEY (KEY_COLOR) = 0
 *
 */
class SpriteCore {
public:
   /**
    * register map
    *
    */
   enum {
      BYPASS_REG = 0x2000,     /**< bypass control register */
      X_REG = 0x2001,          /**< x-axis of sprite origin */
      Y_REG = 0x2002,          /**< y-axis of sprite origin */
      SPRITE_CTRL_REG = 0x2003 /**< sprite control register */
   };
   /**
    * symbolic constants
    *
    */
   enum {
      KEY_COLOR = 0,  /**< chroma-key color */
   };
   /* methods */
   SpriteCore(uint32_t core_base_addr, int size);
   ~SpriteCore();                  // not used

   /**
    * write a 32-bit word to memory module/registers of a video core
    * @param addr offset address within core
    * @param color data to be written
    *
    */
   void wr_mem(int addr, uint32_t color);

   /**
    * move sprite to a location
    * @param x x-coordinate of sprite origin
    * @param y y-coordinate of sprite origin
    *
    * @note origin is the top-left corner of sprite
    */
   void move_xy(int x, int y);

   /**
    * write sprite control command
    * @param cmd control command
    *
    */
   void wr_ctrl(int32_t cmd);

   /**
    * enable/disable core bypass
    * @param by 1: bypass current core; 0: not bypass
    * @note type of command depends on each individual sprite core
    */
   void bypass(int by);

private:
   uint32_t base_addr;
   int size;   // sprite memory size
};

/**********************************************************************
 * OSD Core
 *********************************************************************/
/**
 * osd (on-screen display) video core driver
 *
 * video subsystem HDL parameter:
 *  - CHROMA_KEY (CHROMA_KEY_COLOR) = 0
 *
 */
class OsdCore {
public:
   /**
    * register map
    *
    */
   enum {
      BYPASS_REG = 0x2000,  /**< bypass control register */
      FG_CLR_REG = 0x2001,  /**< foreground color register */
      BG_CLR_REG = 0x2002   /**< background color register */
   };
   /**
    * symbolic constants
    *
    */
   enum {
      CHROMA_KEY_COLOR = 0,   // chroma key
      NULL_CHAR = 0x00,       // signature for transparent char tile
      CHAR_X_MAX = 80,        // 80 char per row
      CHAR_Y_MAX = 30         // 30 char per column
   };
   /* methods */
   OsdCore(uint32_t core_base_addr);
   ~OsdCore();
   // not used

   /**
    * set foreground/background text display colors
    * @param fg_color foreground text display color
    * @param bg_color background text display color
    *
    */
   void set_color(uint32_t fg_color, uint32_t bg_color);

   /**
    * write a char to tile RAM
    * @param x x-coordinate of the tile (between 0 and CHAR_X_MAX)
    * @param y y-coordinate of the tile (between 0 and CHAR_Y_MAX)
    * @param ch char to be written
    * @param reverse 0: normal display; 1: reversed display
    *
    * @note reversed display swaps the foreground/background colors
    *
    */
   void wr_char(uint8_t x, uint8_t y, char ch, int reverse = 0);

   /**
    * clear tile RAM (by writing NULL_CHAR to all tiles)
    *
    */
   void clr_screen();

   /**
    * enable/disable core bypass
    * @param by 1: bypass current core; 0: not bypass
    *
    */
   void bypass(int by);
private:
   uint32_t base_addr;
};

/**********************************************************************
 * Frame Core
 *********************************************************************/
/**
 * frame buffer core driver
 *
 */
class FrameCore {
public:
   /**
    * Register map
    *
    */
   enum {
      BYPASS_REG = 0xfffff  /**< bypass control register */
   };
   /**
    * Symbolic constants for frame buffer size
    *
    */
   enum {
    HMAX = 640,  /**< 640 pixels per row */
    VMAX = 480   /**< 480 pixels per row */
   };
   /* methods */
   FrameCore(uint32_t frame_base_addr);
   ~FrameCore();                  // not used

   /**
    * write a pixel to frame buffer
    * @param x x-coordinate of the pixel (between 0 and HMAX)
    * @param y y-coordinate of the pixel (between 0 and VMAX)
    * @param color pixel color
    *
    */
   void wr_pix(int x, int y, int color);

   /**
    * clear frame buffer (fill the frame with a specific color)
    * @param color color to fill the frame
    *
    */
   void clr_screen(int color);


   /**
    * generate pixels for a line in frame buffer (plot a line)
    * @param x1 x-coordinate of starting point
    * @param y1 y-coordinate of starting point
    * @param x2 x-coordinate of ending point
    * @param y2 y-coordinate of ending point
    * @param color line color
    *
    */
   void plot_line(int x1, int y1, int x2, int y2, int color);

   /**
    * enable/disable core bypass
    * @param by 1: bypass current core; 0: not bypass
    *
    */
   void bypass(int by);


private:
   uint32_t base_addr;
   void swap(int &a, int &b);
};

#endif  // _VGA_H_INCLUDED
