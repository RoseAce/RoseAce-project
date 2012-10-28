#include <stdint.h>
typedef uint16_t u16; //Pour ce relou de gpmc.h...
typedef uint32_t u32;
typedef uint8_t u_char;
#include "/usr/src/linux/arch/arm/plat-omap/include/plat/gpmc.h"
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "roseace_gpmc.h"

#define CS1

#define PADCONF_ADDRESS 0x48002000
#define GPMC_NCS7 0xbc
#define CONTROL_PROG_IO0 0x444

static unsigned long* gpmc_reg;
static unsigned long* padconf_gpmc;

void roseace_init_gpmc() {
  int fd = -1;

  if ((fd = open("/dev/mem", O_RDWR)) == -1)
    return;
  
  gpmc_reg = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t) 0x6e000000);
  padconf_gpmc = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t) PADCONF_ADDRESS);

  if(padconf_gpmc==MAP_FAILED)
  {
    perror("Error on PADCONF mapping");
    exit(1);
  }

  *(padconf_gpmc + GPMC_NCS7/sizeof(long)) |= 0x01000000;
  *(padconf_gpmc + GPMC_NCS7/sizeof(long)) &= 0xf1f8ffff;
  *(padconf_gpmc + CONTROL_PROG_IO0/sizeof(long)) &= ~0x00000040;

  *(gpmc_reg + 50 / sizeof(long)) |= 0x10; //WriteProtect = 1

#ifdef CS0
  gpmc_reg += 0x60 / sizeof(long); //CS0 = 0x60, puis +0x30 par CS
#elif defined CS1
  gpmc_reg += 0x90 / sizeof(long); //CS0 = 0x60, puis +0x30 par CS
#endif
  
  *(gpmc_reg + GPMC_CS_CONFIG7 / sizeof(long)) &= !GPMC_CONFIG7_CSVALID;
  __asm__("nop\n");
  
  *(gpmc_reg + GPMC_CS_CONFIG1 / sizeof(long)) = 
    GPMC_CONFIG1_WRITETYPE_SYNC
    | GPMC_CONFIG1_READTYPE_SYNC 
    //+ GPMC_CONFIG1_WAIT_WRITE_MON //only use in ASYNC mode
    //+ GPMC_CONFIG1_WAIT_PIN_SEL(0) //only use in ASYNC mode
    | GPMC_CONFIG1_DEVICESIZE_16 
    | GPMC_CONFIG1_DEVICETYPE_NOR
    | GPMC_CONFIG1_FCLK_DIV(3)
    | GPMC_CONFIG1_MUXADDDATA
    | GPMC_CONFIG1_CLKACTIVATIONTIME(4);

  *(gpmc_reg + GPMC_CS_CONFIG2 / sizeof(long)) =
    GPMC_CONFIG2_CSONTIME(4)
    | GPMC_CONFIG2_CSWROFFTIME(24)
    | GPMC_CONFIG2_CSRDOFFTIME(24);

  *(gpmc_reg + GPMC_CS_CONFIG3 / sizeof(long)) =
    GPMC_CONFIG3_ADVONTIME(4)
    | GPMC_CONFIG3_ADVRDOFFTIME(12)
    | GPMC_CONFIG3_ADVWROFFTIME(12);

  *(gpmc_reg + GPMC_CS_CONFIG4 / sizeof(long)) =
    GPMC_CONFIG4_WEONTIME(12)
    | GPMC_CONFIG4_WEOFFTIME(24)
    | GPMC_CONFIG4_OEONTIME(12)
    | GPMC_CONFIG4_OEOFFTIME(24);
    
  *(gpmc_reg + GPMC_CS_CONFIG5 / sizeof(long)) =
    GPMC_CONFIG5_RDACCESSTIME(16)
    | GPMC_CONFIG5_PAGEBURSTACCESSTIME(8)
    | GPMC_CONFIG5_WRCYCLETIME(31)
    | GPMC_CONFIG5_RDCYCLETIME(31);

  *(gpmc_reg + GPMC_CS_CONFIG6 / sizeof(long)) =
    GPMC_CONFIG6_WRACCESSTIME(16)
    | GPMC_CONFIG6_WRDATAONADMUXBUS(12)
    | GPMC_CONFIG6_CYCLE2CYCLEDELAY(4)
    | GPMC_CONFIG6_BUSTURNAROUND(0);

  //16MB size, CSVALID & 8*16MB base address
#ifdef CS0
  *(gpmc_reg + GPMC_CS_CONFIG7 / sizeof(long)) = 0x00000f40; //Pour CS0
#elif defined CS1
  *(gpmc_reg + GPMC_CS_CONFIG7 / sizeof(long)) = 0x00000f48; //Pour CS1
#endif
  __asm__("nop\n");

  if ((fd = open("/dev/mem", O_RDWR)) == -1)
    return;
  
#ifdef CS0
  gpmc_short = mmap(NULL, 0x01000000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t) 0x00000000); //For CS0
  gpmc_long = mmap(NULL, 0x01000000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t) 0x00000000); //For CS0
#elif defined CS1
  gpmc_short = mmap(NULL, 0x01000000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t) 0x08000000); //For CS1
  gpmc_long = mmap(NULL, 0x01000000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t) 0x08000000); //For CS1
#endif
  
  __asm__ __volatile__ ("dsb" : : : "memory");
}

