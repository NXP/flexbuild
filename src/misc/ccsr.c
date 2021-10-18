/* Copyright 2018,2019 NXP
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

/*
 * Simple program for reading/writing CCSR registers on NXP Layerscape platforms
 */

#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64

#define CCSR_BASE 0x1000000LL
#define CCSR_SIZE (240*1024*1024)

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>
#include <string.h>

#define MEMDEVICE "/dev/mem"

char
*map_to_user (__off64_t address, unsigned long size)
{
  int fd;
  char *p;


  /* Choose O_SYNC to make cache-inhibited and guarded on PPC */
  fd = open(MEMDEVICE, O_RDWR | O_SYNC);
  if (fd == -1) {
    perror("open");
    fprintf(stderr, "Could not open %s\n", MEMDEVICE);
    exit(EXIT_FAILURE);
  }

  p = mmap64(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, address);

  if (p == MAP_FAILED) {
    perror("mmap");
    exit(EXIT_FAILURE);
  }

  /* memory stays mapped after the fd is closed */
  close(fd);

  return p;
}


void usage(void)
{
  fprintf(stderr, "Read:  ccsr address [count]\n");
  fprintf(stderr, "Write: ccsr -w addr value [count]\n");

  exit(EXIT_FAILURE);
}

int main(int argc, char **argv)
{
  char *p, *tmp;
  int writing;
  unsigned long addr, value, count, i;

  if (argc < 2) usage();

  if (strcmp(argv[1], "-w") == 0) {

    writing = 1;
    if (argc < 4) usage();

    addr = strtoul(argv[2], &tmp, 0);
    if(*tmp != 0) {
      fprintf(stderr, "Error: address not a number\n");
      exit(EXIT_FAILURE);
    }

    value = strtoul(argv[3], &tmp, 0);
    if(*tmp != 0) {
      fprintf(stderr, "Error: value not a number\n");
      exit(EXIT_FAILURE);
    }

    if (argc == 5) {
      count = strtoul(argv[4], &tmp, 0);
      if(*tmp != 0) {
	fprintf(stderr, "Error: count not a number\n");
	exit(EXIT_FAILURE);
      }
    } else {
      count = 1;
    }

  } else {

    writing = 0;

    addr = strtoul(argv[1], &tmp, 0);
    if(*tmp != 0) {
      fprintf(stderr, "Error: address not a number\n");
      exit(EXIT_FAILURE);
    }

    if (argc == 3) {
      count = strtoul(argv[2], &tmp, 0);
      if(*tmp != 0) {
	fprintf(stderr, "Error: count not a number\n");
	exit(EXIT_FAILURE);
      }
    } else {
      count = 1;
    }

  }

  if ((p = (char *) map_to_user(CCSR_BASE, CCSR_SIZE)) == NULL) {
    fprintf(stderr, "Error: could not map CCSR\n");
    return EXIT_FAILURE;
  }

  addr = addr & (~3);

  if ((addr < CCSR_BASE) || (addr + 4 > CCSR_BASE + CCSR_SIZE)) {
    fprintf(stderr, "Error: address is outside of CCSR address space\n");
    return EXIT_FAILURE;
  }

  if (writing) {
    printf("writing: %lx = %lx, count = %lx\n", addr, value, count);
    for (i = 0; i < count; i++)
      *(volatile uint32_t *)(p + (4*i + addr - CCSR_BASE)) = value;
  } else {
    printf("Reading: %lx, count = %lx\n", addr, count);
    for (i = 0; i < count; i++)
      printf("0x%08lx: 0x%08x\n", 4*i + addr, *(volatile uint32_t *)(p + (4*i + addr - CCSR_BASE)));
  }

  return EXIT_SUCCESS;
}
