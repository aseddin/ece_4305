/*****************************************************************//**
 * @file adsr_core.cpp
 *
 * @brief implementation of AdsrCore class
 *
 * @author p chu
 * @version v1.0: initial release
 ********************************************************************/

#include "adsr_core.h"

AdsrCore::AdsrCore(uint32_t adsr_base_addr, DdfsCore *ddfs) {
   base_addr = adsr_base_addr;
   _ddfs = ddfs;
   init();
   select_env(1);
}
AdsrCore::~AdsrCore() {
}     // not used

void AdsrCore::init() {
   _ddfs->set_env_source(1);  //select external env source (i.e., adsr)
   _ddfs->set_fow_source(0);
   _ddfs->set_pha_source(0);
   // set note C
   _ddfs->set_carrier_freq(262);
   _ddfs->set_offset_freq(0);
   _ddfs->set_phase_degree(0);
}

int AdsrCore::idle() {
   int idle_bit;

   // read status register
   idle_bit = (int) io_read(base_addr, 0) & 0x00000001;
   return (idle_bit);
}

void AdsrCore::start() {
   // write a dummy data to generate a start pulse
   io_write(base_addr, START_REG, 0);
}


void AdsrCore::abort() {
   // write 0 to attack register
   // ams = STOP_PATTERN;
   io_write(base_addr, ATK_REG, (uint32_t )STOP_PATTERN);
   //write_adsr_reg();
}


void AdsrCore::bypass() {
   ams = BYPASS_PATTERN;
   io_write(base_addr, ATK_REG, (uint32_t )BYPASS_PATTERN);
   // write_adsr_reg();
}

void AdsrCore::set_env(int attack_ms, int decay_ms, int sustain_ms, int release_ms, float sus_level) {
   ams = attack_ms;
   dms = decay_ms;
   sms = sustain_ms;
   rms = release_ms;
   slevel = sus_level;
   write_adsr_reg();
}


void AdsrCore::select_env(int n) {
   switch (n) {
   case 1:
      set_env(100, 50, 100, 50, 0.9);
      break;
   case 2:
      set_env(10, 50, 100, 100, 0.9);
      break;
   default:
      set_env(10, 200, 100, 100, 0.1);
      break;
   }
   return;
}

void AdsrCore::play_note(int note, int oct, int dur) {
   int sus_tmp;
   int freq;

   freq = calc_note_freq(oct, note);
   _ddfs->set_carrier_freq(freq);

   sus_tmp = dur - (ams + dms + rms);
   if (sus_tmp <= 0) {
      // sustain time must be greater than 0
      sus_tmp = 10;
   }
   set_env(ams, dms, sus_tmp, rms, slevel);
   // start envelope
   //wait_pwm_0_crossing();
   io_write(base_addr, START_REG, 0);
}


int AdsrCore::calc_note_freq(int oct, int ni) {
   // frequency table for octave 0
   const float NOTES[] = { 16.3516,   //  0 C
         17.3239,   //  1 C#
         18.3541,   //  2 D
         19.4454,   //  3 D#
         20.6017,   //  4 E
         21.8268,   //  5 F
         23.1247,   //  6 F#
         24.4997,   //  7 G
         25.9565,   //  8 G#
         27.5000,   //  9 A
         29.1352,   // 10 A#
         30.8677    // 11 B
         };
   int freq;

   // frequency in octave i: (f in oct 0)*2^i
   freq = (unsigned int) NOTES[ni] * (1 << oct);
   return (freq);
}

void AdsrCore::write_adsr_reg() {
   uint32_t nc, step, sus_abs;
   //# clocks per ms = 0.001 / (1/(SYS_CLK_FREQ*1000000))
   const uint32_t clks = SYS_CLK_FREQ * 1000;

   if (ams == BYPASS_PATTERN) {
      io_write(base_addr, ATK_REG, (uint32_t )BYPASS_PATTERN);
      return;
   }
   if (ams == STOP_PATTERN) {
      io_write(base_addr, ATK_REG, (uint32_t )STOP_PATTERN);
      return;
   }

   // convert sustain level in absolute value
   sus_abs = (unsigned int) MAX * slevel;
   io_write(base_addr, SUS_LEVEL_REG, (uint32_t )sus_abs);
   // convert attack time (in ms) into envelope increment step
   nc = ams * clks;
   step = MAX / nc;              // increment step
   if (step == 0)
      step = 1;
   io_write(base_addr, ATK_REG, (uint32_t )step);
   debug("adsr set - sus_level/atk_step: ", sus_abs, step);
   // convert decay time (in ms) into envelope decrement step
   nc = dms * clks;
   step = (MAX - sus_abs) / nc;
   if (step == 0)
      step = 1;
   io_write(base_addr, DCY_REG, (uint32_t )step);
   // convert sustain time (in ms) into #clocks
   nc = sms * clks;
   io_write(base_addr, SUS_REG, (uint32_t )nc);
   debug("adsr set - sus_time/dcy_step: ", nc, step);
   // convert release time (in ms) into envelope decrement step
   nc = rms * clks;
   step = sus_abs / nc;
   if (step == 0)
      step = 1;
   io_write(base_addr, REL_REG, (uint32_t )step);
}

