# Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
# All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0


CFLAGS=-Wall -Wstrict-prototypes -O2 -m64

2405ai: 2405ai.o conio.o
	gcc -o 2405ai 2405ai.o conio.o -lusb_dask64 -lmosquitto -lm -I/usr/include/json-c -ljson-c

2405ai.o: 2405ai.c
	gcc -c $(CFLAGS) -I../../../include 2405ai.c

conio.o: ../../conio/conio.c
	gcc -c $(CFLAGS) -I../../../include ../../conio/conio.c

clean:
	rm -f 2405ai *.o *.dat
