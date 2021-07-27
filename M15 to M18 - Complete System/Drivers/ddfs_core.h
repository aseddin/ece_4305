/*****************************************************************//**
 * @file ddfs_core.h
 *
 * @brief configure and control MMIO ddfs core
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

#ifndef _DDFS_H_INCLUDED
#define _DDFS_H_INCLUDED

#include "chu_init.h"

/**
 * ddfs core driver:
 * - configure and control MMIO ddfs core.
 * - connect amp/freq/phase modulation signals to external
 *   sources or core's registers
 *
 * MMIO subsystem HDL parameter:
 *  - PW (PHA_WIDTH): # bits in ddfs phase register
 */
class DdfsCore {
public:
   /**
    * register map
    *
    */
	enum {
		FCW_REG = 0,    /**< carrier frequency control word register */
		FOW_REG = 1,    /**< offset frequency control word register */
		PHA_REG = 2,    /**< phase control word register */
		ENV_REG = 3,    /**< envelope (amplitude) control word register */
		SRC_SEL_REG = 4 /**<source selection register */
	};

   /**
    * symbolic constant
    *
    */
	enum {
		PHA_WIDTH = 30  /**< bits in ddfs phase register */
	};

	/* methods */
	/**
	 * Constructor
	 *
	 * @note constructor call init() to configure the ddfs core
	 */
	DdfsCore(uint32_t core_base_addr);
	~DdfsCore();                  // not used

	/**
	 * set ddfs default configuration (amp=1.0; freq=262Hz)
	 *
	 */
   void init();

   /**
	 * set ddfs carrier freq
	 *
	 * @param freq carrier frequency
	 *
	 */
	void set_carrier_freq(int freq);

	/**
	 * set ddfs offset (delta) freq
	 *
	 * @param freq offset frequency
	 *
	 */
	void set_offset_freq(int freq);

	/**
	 * set ddfs phase shift
	 *
	 * @param phase ddfs phase shift in degree
	 *
	 */
	void set_phase_degree(int phase);

	/**
	 * set ddfs envelope (amplitude)
	 *
	 * @param env envelope value between -1.0 and 1.0
	 *
	 */
	void set_env(float env);

	/**
	 * select fow source
	 *
	 * @param channel (0: internal register; 1: external source)
	 *
	 */
	void set_fow_source(int channel);

	/**
	 * select envelope source
	 *
	 * @param channel (0: internal register; 1: external source)
	 *
	 */
	void set_env_source(int channel);

	/**
	 * select phase source
	 *
	 * @param channel (0: internal register; 1: external source)
	 *
	 */
	void set_pha_source(int channel);

	/**
	 * read ddfs pwm value
	 *
	 */
	int16_t read_pcm();


private:
	/* variable to keep track of current status */
	uint32_t base_addr;
	uint32_t ch_select_reg;

};

#endif  // _DDFS_H_INCLUDED
