/* 
* Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
* All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

#include <termio.h>

void restore(struct termio *tty_save);
char getch(void);
char kb_hit(void);
int  kbhit(void);
