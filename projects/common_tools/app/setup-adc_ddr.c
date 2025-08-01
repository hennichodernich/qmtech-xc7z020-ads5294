#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

#define NUM_COMMANDS 5

int main(int argc, char *argv[])
{
  int i, fd, value, ddr_mode = 2;

  uint8_t data[NUM_COMMANDS * 3] =
  {
    0x00, 0x00, 0x01,	//RESET
    0x46, 0x84, 0x0C,	//14bit, DDR, MSB first, 2s complement, 1-wire
    0x42, 0x00, 0x00,	//PHASE_DDR=00
    0x28, 0x81, 0x00,	//EN_BITORDER=1, BIT_WISE=1
    0x25, 0x00, 0x40,	//EN_RAMP
  };

  if (argc > 1){
	  i = atoi(argv[1]);
	  if ((i>=0) && (i<=3))
		  ddr_mode = i;
  }

  data[8] |= (ddr_mode & 0x03) << 5;

  fd = open("/dev/spidev0.0", O_RDWR);

  value = SPI_MODE_0;
  ioctl(fd, SPI_IOC_WR_MODE, &value);

  value = 8;
  ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &value);

  value = 1000000;
  ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &value);

  for (i=0;i<NUM_COMMANDS;++i){
  	printf("%02x %02x %02x\n",data[i*3],data[i*3+1],data[i*3+2]);
  	write(fd, &data[i*3], 3);
        if(i==0)
	    sleep(1);
  }

  close(fd);

  return EXIT_SUCCESS;
}
