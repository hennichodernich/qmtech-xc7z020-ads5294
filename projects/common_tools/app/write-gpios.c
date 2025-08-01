#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char *argv[])
{
  int fd, i;
  volatile void *baseaddr;
  volatile uint32_t *data_word;

  if(argc != 2)
  {
    fprintf(stderr, "requires byte in decimal\n");
    return EXIT_FAILURE;
  }

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  baseaddr = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0xA0000000);

  data_word = (uint32_t *)(baseaddr);

  i = atoi(argv[1]);
  if ((i<0) || (i>255))
  {
    fprintf(stderr, "argument out of range\n");
    return EXIT_FAILURE;
  }
  *data_word = (uint8_t)i | ((uint8_t)i << 8) | ((uint8_t)i << 16) | ((uint8_t)i << 24);


  return EXIT_SUCCESS;
}
