/* 
* Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
* All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

#ifndef _USBDAQ_THERMO_COUPLE_H
#define _USBDAQ_THERMO_COUPLE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef basic_type
#define basic_type

typedef uint8_t            U8;
typedef int16_t            I16;
typedef uint16_t           U16;
typedef int32_t            I32;
typedef uint32_t           U32;
typedef int64_t            I64;
typedef uint64_t           U64;
typedef float              F32;
typedef double             F64;
typedef enum{FALSE, TRUE} BOOLEAN;

#define FIRSTBYTE(VALUE)  (VALUE&0x00FF)
#define SECONDBYTE(VALUE) ((VALUE>>8)&0x00FF)
#define THIRDBYTE(VALUE)  ((VALUE>>16)&0x00FF)
#define FOURTHBYTE(VALUE) ((VALUE>>24)&0x00FF)
#endif


#define THERMO_B_TYPE      1
#define THERMO_C_TYPE      2
#define THERMO_E_TYPE      3
#define THERMO_K_TYPE      4
#define THERMO_R_TYPE      5
#define THERMO_S_TYPE      6
#define THERMO_T_TYPE      7
#define RTD_PT100          8
#define THERMO_MAX_TYPE    8

#define NoThermoError                  0

#define ErrorInvalidThermoType      -601
#define ErrorOutThermoRange         -602
#define ErrorThermoTable            -603


I16 ADC_to_Thermo( U16 wThermoType, double fScaledADC, double fColdJuncTemp, double* pfTemp );


#ifdef __cplusplus
}
#endif

#endif // _USBDAQ_THERMO_COUPLE_H
