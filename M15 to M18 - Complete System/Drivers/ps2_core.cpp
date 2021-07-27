/*****************************************************************//**
 * @file ps2_core.cpp
 *
 * @brief implementation of Ps2Core class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/


#include "ps2_core.h"

Ps2Core::Ps2Core(uint32_t core_base_addr) {
   base_addr = core_base_addr;
}

Ps2Core::~Ps2Core() {
}

int Ps2Core::rx_fifo_empty() {
   uint32_t rd_word;
   int empty;

   rd_word = io_read(base_addr, RD_DATA_REG);
   empty = (int) (rd_word & RX_EMPT_FIELD) >> 8;
   return (empty);
}

int Ps2Core::tx_idle() {
   uint32_t rd_word;
   int idle;

   rd_word = io_read(base_addr, RD_DATA_REG);
   idle = (int) (rd_word & TX_IDLE_FIELD) >> 9;
   return (idle);
}

void Ps2Core::tx_byte(uint8_t cmd) {
   io_write(base_addr, PS2_WR_DATA_REG, (uint32_t ) cmd);
}

int Ps2Core::rx_byte() {
   uint32_t data;

   if (rx_fifo_empty())  // no data
      return (-1);
   else {
      data = io_read(base_addr, RD_DATA_REG) & RX_DATA_FIELD;
      io_write(base_addr, RM_RD_DATA_REG, 0); //dummy write to remove data from rx FIFO
      return ((int) data);
   }
}

/* procedure:
 *    1. flush ps2 receiver fifo
 *    2. host sends reset command 0xff
 *    3. ps2 device acknowledges (0xfa) and performs self-test
 *    4. ps2 device responds 0xaa if test passes
 *    5a. keyboard sends no additional data
 *    5b. mouse sends an extra id 0x00
 *    6. host sends 0xf4 to start stream mode
 *    7. mouse acknowledges (0xfa)
 */
int Ps2Core::init() {
   int packet;

   /* flush fifo buffer */
   while (!rx_fifo_empty()) {
      rx_byte();
   }
   /* send reset 0xff  */
   debug("ps2 reset: write command ", 0, 0);
   tx_byte(0xff);
   sleep_ms(2000);    // 200 ms not long enough for USB keyboard
   /* check 0xfa 0xaa */
   if (rx_byte() != 0xfa) {
      return (-1);        // no response or wrong response
   }
   if (rx_byte() != 0xaa) {
      return (-1);        // no response or wrong response
   }
   debug("ps2 reset: 0xfa 0xaa valid ", 0, 0);
   /* check whether 0x00 is received */
   packet = rx_byte();
   if (packet == -1) {
      return (1);        // fifo has no more packet, device is keyboard
   }
   if (packet != 0x00) {
      return (-2); // unknown ps2 device (unlikely)
   }
   /* device is a mouse; set it to stream mode */
   tx_byte(0xf4);
   sleep_ms(100);
   /* check 0xfa (acknowledge) */
   if (rx_byte() != 0xfa) {
      return (-3);        // no response or wrong response
   }
   return (2);  //success
}

int Ps2Core::get_mouse_activity(int *lbtn, int *rbtn, int *xmov,
      int *ymov) {
   uint8_t b1, b2, b3;

   uint32_t tmp;

   /* check and retrieve 1st byte */
   if (rx_fifo_empty())
      return (0);                         // no data in rx fifo buffer
   b1 = rx_byte();
   /* wait and retrieve 2nd byte */
   while (rx_fifo_empty())
      ;
   b2 = rx_byte();
   /* wait and retrieve 3rd byte */
   while (rx_fifo_empty())
      ;
   b3 = rx_byte();
   /* extract button info */
   *lbtn = (int) (b1 & 0x01);      // extract bit 0
   *rbtn = (int) (b1 & 0x02) >> 1; // extract bit 1
   /* extract x movement; manually convert 9-bit 2's comp to int */
   tmp = (uint32_t) b2;
   if (b1 & 0x10)                // check MSB (sign bit) of x movement
      tmp = tmp | 0xffffff00;    // manual sign-extension if negative
   *xmov = (int) tmp;            // data conversion
   /* extract y movement; manually convert 9-bit 2's comp to int */
   tmp = (uint32_t) b3;
   if (b1 & 0x20)                // check MSB (sign bit) of y movement
      tmp = tmp | 0xffffff00;     // manual sign-extension if negative
   *ymov = (int) tmp;            // data conversion
   /* success */
   return (1);
}

int Ps2Core::get_kb_ch(char *ch) {
   // special  characters
#define TAB     0x09   // tab
#define BKSP    0x08   // backspace
#define ENTER   0x0d   // enter (new line)
#define ESC     0x1b   // escape
#define BKSL    0x5c   // back slash
#define SFT_L   0x12   // left shift
#define SFT_R   0x59   // right shift

#define CAPS    0x80
#define NUM     0x81
#define CTR_L   0x82
#define F1      0xf0
#define F2      0xf1
#define F3      0xf2
#define F4      0xf3
#define F5      0xf4
#define F6      0xf5
#define F7      0xf6
#define F8      0xf7
#define F9      0xf8
#define F10     0xf9
#define F11     0xfa
#define F12     0xfb

   // keyboard scan code to ascii (lowercase)
   static const uint8_t SCAN2ASCII_LO_TABLE[128] = {
         0, F9, 0, F5, F3, F1,   F2, F12,        //00
         0, F10, F8, F6, F4, TAB, '`', 0,        //08
         0, 0, SFT_L, 0, CTR_L, 'q', '1', 0,     //10
         0, 0, 'z', 's', 'a', 'w', '2', 0,       //18
         0, 'c', 'x', 'd', 'e', '4', '3', 0,     //20
         0, ' ', 'v', 'f', 't', 'r', '5', 0,     //28
         0, 'n', 'b', 'h', 'g', 'y', '6', 0,     //30
         0, 0, 'm', 'j', 'u', '7', '8', 0,       //38
         0, ',', 'k', 'i', 'o', '0', '9', 0,     //40
         0, '.', '/', 'l', ';', 'p', '-', 0,     //48
         0, 0, '\'', 0, '[', '=', 0, 0,          //50
         CAPS, SFT_R, ENTER, ']', 0, BKSL, 0, 0, //58
         0, 0, 0, 0, 0, 0, BKSP, 0,              //60
         0, '1', 0, '4', '7', 0, 0, 0,           //68
         0, '.', '2', '5', '6', '8', ESC, NUM,   //70
         F11, '+', '3', '-', '*', '9', 0, 0      //78
         };
   // keyboard scan code to ascii (uppercase)
   static const uint8_t SCAN2ASCII_UP_TABLE[128] = {
         0, F9, 0, F5, F3, F1, F2, F12,         //00
         0, F10, F8, F6, F4, TAB, '~', 0,       //08
         0, 0, SFT_L, 0, CTR_L, 'Q', '!', 0,    //10
         0, 0, 'Z', 'S', 'A', 'W', '@', 0,      //18
         0, 'C', 'X', 'D', 'E', '$', '#', 0,    //20
         0, ' ', 'V', 'F', 'T', 'R', '%', 0,    //28
         0, 'N', 'B', 'H', 'G', 'Y', '^', 0,    //30
         0, 0, 'M', 'J', 'U', '&', '*', 0,      //38
         0, '<', 'K', 'I', 'O', ')', '(', 0,    //40
         0, '>', '?', 'L', ':', 'P', '_', 0,    //48
         0, 0, '\"', 0, '{', '+', 0, 0,         //50
         CAPS, SFT_R, ENTER, '}', 0, '|', 0, 0, //58
         0, 0, 0, 0, 0, 0, BKSP, 0,             //60
         0, '1', 0, '4', '7', 0, 0, 0,          //68
         0, '.', '2', '5', '6', '8', ESC, NUM,  //70
         F11, '+', '3', '-', '*', '9', 0, 0     //78
         };

   static int sft_on = 0;
   uint8_t scode;

   while (1) {
      if (rx_fifo_empty())         // no packet
         return (0);
      scode = rx_byte();
      switch (scode) {
      case 0xf0:                 // break code
         while (rx_fifo_empty())
            ; // get next
         scode = rx_byte();
         if (scode == SFT_L || scode == SFT_R)
            sft_on = 0;
         break;
      case SFT_L:                 // shift key make code
      case SFT_R:
         sft_on = 1;
         break;
      default:                    // normal make code
         if (sft_on)
            *ch = SCAN2ASCII_UP_TABLE[scode];
         else
            *ch = SCAN2ASCII_LO_TABLE[scode];
         return (1);
      }  // end switch
   }  // end while
}

