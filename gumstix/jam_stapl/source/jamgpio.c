/*gpio_communication.c*/
/*This file implements fucntion which are use to command GPIO to program FPGA thanks to it JTAG interface*/
/*The pin assignement is the following :
GPIO77 --> GPIO3[13] -- >TMS output
GPIO78 --> GPIO3[14] --> TDO input
GPIO79 --> GPIO3[15] --> TCK output
GPIO89 --> GPIO3[25] --> TDI output */

/*Included files*/
#include <sys/mman.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

/*Constant definition*/
#define MAP_SIZE 4096
#define GPIO3_ADDRESS 0x49052000
#define GPIO5_ADDRESS 0x49056000
#define CM_FCLKEN_PER 0x48005000 //use to activate GPIO clock
#define PADCONF_ADDRESS 0x48002000
#define CONTROL_PADCONF_DSS_DATA6 0xe8 //use for GPIO3[77] selection
#define CONTROL_PADCONF_DSS_DATA8 0xec //use for GPIO3[78] and GPIO3[79] selection
#define CONTROL_PADCONF_DSS_DATA18 0x100 //use for GPIO3[89] selection
#define CONTROL_PADCONF_UART2_CTS 0x174 //use for GPIO144 (on tobi)

/*The following data are the offsets for GPIO*/
#define GPIO_OE 0x34
#define GPIO_DATAOUT 0x03C
#define GPIO_DATAIN 0x038

/*Global variables*/
static unsigned long* gpio3;
static unsigned long* gpio5;
static unsigned long* gpio_clk;
static unsigned long* gpio_padconf;

/*This function initialize the GPIO interface for the communication*/
void interface_init()
{
  
  int fd = open("/dev/mem", O_RDWR | O_SYNC);
  if (fd<0) {
    perror("open(\"/dev/mem\")");
    exit(-1);
  }
  /*GPIO3 is mapped on the memory*/
  gpio3 = mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)GPIO3_ADDRESS);
  if(gpio3==MAP_FAILED)
  {
    perror("GPIO3 map failed\n");
    exit(-1);
  }
  /*GPIO5 is mapped on the memory*/
  gpio5 = mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)GPIO5_ADDRESS);
  if(gpio5==MAP_FAILED)
  {
    perror("GPIO3 map failed\n");
    exit(-1);
  }
  /*Register clock activation for GPIO3 is mapped on memory*/
  gpio_clk = mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)CM_FCLKEN_PER);
  if(gpio_clk==MAP_FAILED)
  {
    perror("GPIO_CLK map failed\n");
    exit(-1);
  }
  /*Padconf register for GPIO3 are mapped on memory*/
  gpio_padconf = mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)PADCONF_ADDRESS);
  if(gpio_padconf==MAP_FAILED)
  {
    perror("GPIO_PADCONF map failed\n");
    exit(-1);
  }
  
  /*GPIO selection*/
  *(gpio_padconf + CONTROL_PADCONF_DSS_DATA6/sizeof(long)) |= 0x00040000;
  *(gpio_padconf + CONTROL_PADCONF_DSS_DATA6/sizeof(long)) &= 0xfef4ffff;
  *(gpio_padconf + CONTROL_PADCONF_DSS_DATA8/sizeof(long)) |= 0x00040104;
  *(gpio_padconf + CONTROL_PADCONF_DSS_DATA8/sizeof(long)) &= 0xfef4fff4;
  *(gpio_padconf + CONTROL_PADCONF_DSS_DATA18/sizeof(long)) |= 0x00040000;
  *(gpio_padconf + CONTROL_PADCONF_DSS_DATA18/sizeof(long)) &= 0xfef4ffff;
  //*(gpio_padconf + CONTROL_PADCONF_UART2_CTS/sizeof(long)) |= 0x00000004;
  //*(gpio_padconf + CONTROL_PADCONF_UART2_CTS/sizeof(long)) &= 0xfffffef4;

  /*Activation of the GPIO3 and GPIO5 clock*/
  *gpio_clk |= 0x00014000;
  
  /*Select GPIO as input/output*/
  /*There are all input after reset*/
  *(gpio3 + GPIO_OE/sizeof(long)) &= 0xfdff5fff;
  //*(gpio5 + GPIO_OE/sizeof(long)) &= 0xfffeffff;
}

void interface_exit()
{
  munmap(gpio3,MAP_SIZE);
  munmap(gpio5,MAP_SIZE);
  munmap(gpio_clk,MAP_SIZE);
  munmap(gpio_padconf, MAP_SIZE);
}

void gpio_set_tdi()
{
  *(gpio3 + GPIO_DATAOUT/sizeof(long)) |= 0x02000000; 
}

void gpio_clear_tdi()
{
  *(gpio3 + GPIO_DATAOUT/sizeof(long)) &= 0xfdffffff; 
}

void gpio_set_tms()
{
  *(gpio3 + GPIO_DATAOUT/sizeof(long)) |= 0x00002000; 
}

void gpio_clear_tms()
{
  *(gpio3 + GPIO_DATAOUT/sizeof(long)) &= 0xffffdfff; 
}

void gpio_set_tck()
{
  *(gpio3 + GPIO_DATAOUT/sizeof(long)) |= 0x00008000; 
}

void gpio_clear_tck()
{
  *(gpio3 + GPIO_DATAOUT/sizeof(long)) &= 0xffff7fff; 
}

void gpio_set_tdo()
{
  //*(gpio3 + GPIO_DATAOUT/sizeof(long)) |= 0x00004000;
  //*(gpio5 + GPIO_DATAOUT/sizeof(long)) |= 0x00010000;
}

void gpio_clear_tdo()
{
  //*(gpio3 + GPIO_DATAOUT/sizeof(long)) &= 0xffffbfff;
  //*(gpio5 + GPIO_DATAOUT/sizeof(long)) &= 0xfffeffff;
}

int gpio_status_tdo()
{
  //printf("%d ", (*(gpio3 + GPIO_DATAIN/sizeof(long)) ));
  return (*(gpio3 + GPIO_DATAIN/sizeof(long)))>>14;
}
