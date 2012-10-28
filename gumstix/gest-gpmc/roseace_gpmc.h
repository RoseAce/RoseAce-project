#ifndef __ROSEACE_GPMC_H
#define __ROSEACE_GPMC_H

volatile unsigned short* gpmc_short;
volatile unsigned long* gpmc_long;

void roseace_init_gpmc();

//Be CAREFULL I changed the 0x000fffff into a 0x001fffff in order not to loose the 20th bit of the address in case that we use it.
static inline void writeh(unsigned short data, long address) {
  // We're writing a short, the address must be even ("pair" for the french which mix the two)
  *(gpmc_short + (address & 0x001fffff) / sizeof(short)) = data;
}

static inline void writel(unsigned long data, long address) {
  //Don't forget that if you write a long in gpmc it will write 2 shorts at address and address+2
  *(gpmc_long + (address & 0x001fffff) / sizeof(long)) = data;
}

static inline unsigned short readh(long address) {
  return(*(gpmc_short + (address & 0x001fffff) / sizeof(short)));
}

static inline unsigned long readl(long address) {
  return(*(gpmc_long + (address & 0x001fffff) / sizeof(long)));
}

//Add of the missing defines of gpmc.h (thanks to Philip Balister)
#define GPMC_CONFIG2_CSWROFFTIME(val)	((val & 31) << 16)
#define GPMC_CONFIG2_CSRDOFFTIME(val)	((val & 31) << 8)
#define GPMC_CONFIG2_CSEXTRADELAY	(1 << 7)
#define GPMC_CONFIG2_CSONTIME(val)	(val & 15)

#define GPMC_CONFIG3_ADVWROFFTIME(val)	((val & 31) << 16)
#define GPMC_CONFIG3_ADVRDOFFTIME(val)	((val & 31) << 8)
#define GPMC_CONFIG3_ADVEXTRADELAY	(1 << 7)
#define GPMC_CONFIG3_ADVONTIME(val)	(val & 15)

#define GPMC_CONFIG4_WEOFFTIME(val)	((val & 31) << 24)
#define GPMC_CONFIG4_WEEXTRADELAY	(1 << 23)
#define GPMC_CONFIG4_WEONTIME(val)	((val & 15) << 16)
#define GPMC_CONFIG4_OEOFFTIME(val)	((val & 31) << 8)
#define GPMC_CONFIG4_OEEXTRADELAY	(1 << 7)
#define GPMC_CONFIG4_OEONTIME(val)	(val & 15)

#define GPMC_CONFIG5_PAGEBURSTACCESSTIME(val)	((val & 15) << 24)
#define GPMC_CONFIG5_RDACCESSTIME(val)	((val & 31) << 16)
#define GPMC_CONFIG5_WRCYCLETIME(val)	((val & 31) << 8)
#define GPMC_CONFIG5_RDCYCLETIME(val)	(val & 31)

#define GPMC_CONFIG6_WRACCESSTIME(val)	((val & 31) << 24)
#define GPMC_CONFIG6_WRDATAONADMUXBUS(val)	((val & 15) << 16)
#define GPMC_CONFIG6_CYCLE2CYCLEDELAY(val)	((val & 15) << 8)
#define GPMC_CONFIG6_CYCLE2CYCLESAMECSEN	(1 << 7)
#define GPMC_CONFIG6_CYCLE2CYCLEDIFFCSEN	(1 << 6)
#define GPMC_CONFIG6_BUSTURNAROUND(val)	(val & 15)

#endif
