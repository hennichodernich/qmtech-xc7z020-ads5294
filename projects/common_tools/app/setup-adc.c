#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

#define NUM_COMMANDS 7

int main(int argc, char *argv[])
{
  int i, fd, value, switch_mode = 0;

  uint8_t data[NUM_COMMANDS * 3] =
  {
    0x00, 0x00, 0x01,	//RESET
    0x46, 0x84, 0x0D,	//14bit, DDR, MSB first, 2s complement, 2-wire
    0x42, 0x00, 0x40,	//PHASE_DDR=2
    0x28, 0x00, 0x00,	//EN_BITORDER=0, BIT_WISE=0
    0x25, 0x00, 0x00,	//normal operation
    0x26, 0xFF, 0xF0,	//12 ones as pattern 1
    0x27, 0x00, 0x00,	//12 zeros as pattern 2
  };

  if (argc > 1){
	  if (*argv[1]=='r')
	  {
		  data[14]=0x40;
		  switch_mode = 1;
	  }
	  else if (*argv[1]=='t')
	  {
		  data[14]=0x23;
		  switch_mode = 1;
	  }
	  else if (*argv[1]=='n')
	  {
		  data[14]=0x00;
		  switch_mode = 1;
	  }
  }

  fd = open("/dev/spidev0.0", O_RDWR);

  value = SPI_MODE_0;
  ioctl(fd, SPI_IOC_WR_MODE, &value);

  value = 8;
  ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &value);

  value = 1000000;
  ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &value);

  if(switch_mode==1)
  {
  	i=4;
  	printf("%02x %02x %02x\n",data[i*3],data[i*3+1],data[i*3+2]);
  	write(fd, &data[i*3], 3);
  }
  else
  {
	  for (i=0;i<NUM_COMMANDS;++i){
  		printf("%02x %02x %02x\n",data[i*3],data[i*3+1],data[i*3+2]);
	  	write(fd, &data[i*3], 3);
        	if(i==0)
		    sleep(1);
	  }
  }

  close(fd);

  return EXIT_SUCCESS;
}
