# Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
# All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

SUBDIRS = 190x 2405 2401 7230 7250 1210

all:
	for i in $(SUBDIRS); do cd "$$i"; $(MAKE); cd ..; done

clean:
	for i in $(SUBDIRS); do cd "$$i"; $(MAKE) clean; rm -f Module.symvers Module.markers modules.order; cd ..; done
	rm -f udask/*.o udask/.*.cmd
