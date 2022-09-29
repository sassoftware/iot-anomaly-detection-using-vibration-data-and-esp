/* 
* Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  
* All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <unistd.h>
#include <string.h>
#include "udask.h"
#include <mosquitto.h>
#include <time.h>
#include <sys/time.h>


#define AI_COUNT 6400 //* Sampling rate per second
#define MAXSIZE 150000
#define NUM_CHANS 4  /* The # of analog input channels*/

int main(int argc, char **argv)
{
    I16 card, err;
    U16 card_num = 0;
	    
    U16 ChanCtrl = ( P2405_AI_EnableIEPE | P2405_AI_Coupling_AC | P2405_AI_PseudoDifferential);
    //U16 ChanCtrl = ( P2405_AI_DisableIEPE | P2405_AI_Coupling_None | P2405_AI_PseudoDifferential);
    U16 ConvSrc = P2405_AI_CONVSRC_INT;	
    U16 TrigMode = P2405_AI_TRGMOD_POST;
    U16 TrigCtrl = P2405_AI_TRGSRC_SOFT;    
    U32 TriggerLvel = 0;  /* Ignore for P1902_AI_TRGSRC_SOFT */
    U32 ReTriggerCount = 0; /*Ignore in Double Buffer Mode*/
    U32 DLY1Cnt = 0; /* Ignore for P2405_AI_TRGSRC_SOFT */
    U32 DLY2Cnt = 0; /* Ignore for P2405_AI_TRGSRC_SOFT */    
    U16 Chans[4] = {0,1,2,3}; /* Array of AI CH numbers */ 
    U32 RDBuffer[AI_COUNT * NUM_CHANS];
    F64 VBuffer[AI_COUNT * NUM_CHANS];
    U32 AI_ReadCount = AI_COUNT * NUM_CHANS; /* AI read count per one buffer */
    F64 fSamplerate = 12800.0f;    
    U32 AccessCnt = 0;
    F64 Sampling_Interval_Time = 1 / fSamplerate; /* Delta time between measurement points */
    F64 Cumulative_MeasTime = 0;  /* Total of measurement time */
    F64 Sensor_Sensitivity_CH0 = 0.100; 	/* Channel 0: [mV/g]  */ 
    //F64 Sensor_Sensitivity_CH1 = 0.100; 	/* Channel 1: [mV/g]  */
    //F64 Sensor_Sensitivity_CH2 = 0.100; 	/* Channel 2: [mV/g]  */
    //F64 Sensor_Sensitivity_CH3 = 0.100; 	/* Channel 3: [mV/g]  */
    F64 D_CH0 = 0;
    //F64 D_CH1 = 0, D_CH2 = 0, D_CH3 = 0; /* Scaled value */
    U32 MeasCount = 0;
    U16 AdRange[4] = {AD_B_10_V, AD_B_10_V, AD_B_10_V, AD_B_10_V};  /* AI range setting of each ch*/
    FILE *w_file;
    char FileName[] = "ai_data.dat";
    U32 i;
    
    /* MQTT & JSON declaration */
    //char msg[150];

    struct mosquitto * mosq;
    int rc;

    /*--------------------------------*/
    /* MQTT Broker setup */
    mosquitto_lib_init();
    mosq = mosquitto_new("publisher-test", true, NULL);
    rc = mosquitto_connect(mosq, "localhost", 1883, 60);
    
    if(rc != 0){
    	printf("Client could not connect to broker! Error Code: %d\n", rc);
	mosquitto_destroy(mosq);
	return -1;
    }
    printf("We are now connected to the broker!\n");


    /* Initialize the buffers */
    memset(RDBuffer, '\0', AI_COUNT*sizeof(U32)*NUM_CHANS); // Buffer for analog input data
    memset(VBuffer, '\0', AI_COUNT*sizeof(F64)*NUM_CHANS);  // Buffer for computed voltage data

    /* File open */
    if(!(w_file=fopen(FileName, "w"))){
        printf("file open error...\n");
        exit(1);
    }
    /* Write header in the file */
    fprintf(w_file, "ID, Time, mSec, CH0(g)\n"); //, CH1(g), CH2(g), CH3(g),\n");

    printf("This sample performs continuous AI acquisition from AI Channel %d, %d, %d and %d\n", Chans[0], Chans[1], Chans[2], Chans[3]);
    printf("at %6.3lf Hz sampling rate.\n\n", fSamplerate);

    /*Open and Initialize Device*/
    card = UD_Register_Card(USB_2405, card_num);
    if(card<0){
        printf("Register_Card Error: %d\n", card);
        fclose(w_file);
        exit(1);
    }

    /*Configure Analog Input Channels*/
    err = UD_AI_2405_Chan_Config( card, ChanCtrl, ChanCtrl, ChanCtrl, ChanCtrl );
    if(err != NoError)
    {
        printf("UD_AI_2405_Chan_Config Error: %d\n", err);
        UD_Release_Card(card);
        fclose(w_file);
        exit(1);
    }
    
    /* Trigger Configuration */
    err = UD_AI_2405_Trig_Config( card, ConvSrc, TrigMode, TrigCtrl, ReTriggerCount, DLY1Cnt, DLY2Cnt, TriggerLvel );
    if(err != NoError)
    {
        printf("UD_AI_2405_Trig_Config Error: %d\n", err);
        UD_Release_Card(card);
        fclose(w_file);
        exit(1);
    }
        
    /* Disable Double Buffer Mode */
    err = UD_AI_AsyncDblBufferMode(card, FALSE); // single-buffer mode
    if(err != NoError)
    {
        printf("UD_AI_AsyncDblBufferMode Error: %d\n", err);
        UD_Release_Card(card);
        fclose(w_file);
        exit(1);
    }

    /* Data Acquisition Start */
    /* Data Acquistion will be continued untill Enter key is pressed */
	
    printf("\nData Acquisition has started...\n");
    MeasCount = 1;    /* # of measurements */
    Cumulative_MeasTime = 0;	/* Total time of measurement */
    int count = 0;
    char msg[MAXSIZE];
    do{
	err = UD_AI_ContReadMultiChannels( card, NUM_CHANS, Chans, AdRange, (U16*)RDBuffer, AI_ReadCount, fSamplerate, SYNCH_OP);
	if(err != NoError){
		printf("UD_AI_ContReadChannel Error: %d\n", err);
		UD_Release_Card(card);
		fclose(w_file);
		exit(1);
	}

	printf("\n\nAI Acquisition Done... Acquired %d samples...\n", AI_ReadCount);
	printf("Write %d samples of Buffer to %s file...\n", AI_ReadCount, FileName);
	printf("Press enter key to stop data acquisition\n");

	/* Convert analog input data(RDBuffer) to computed voltage data(VBuffer) */
	/* USB-2405 has the same measurement range for all channels. So we apply the same range value, AdRange[0] */
	UD_AI_ContVScale32(card, AdRange[0], 0, RDBuffer, VBuffer, AI_ReadCount);
    	char msg1[300];
        for(i=1; i<= 3200; i++){		
		D_CH0 = VBuffer[4*i+0] / Sensor_Sensitivity_CH0; /* Scaled value = V / Sensitivity */
		//D_CH1 = VBuffer[4*i+1] / Sensor_Sensitivity_CH1;
		//D_CH2 = VBuffer[4*i+2] / Sensor_Sensitivity_CH2;
		//D_CH3 = VBuffer[4*i+3] / Sensor_Sensitivity_CH3;
		if (count==0){
			snprintf( msg1, sizeof(msg1), "I,N,%u,%f,1",count+1,D_CH0);
		}else{
			snprintf( msg1, sizeof(msg1), "\nI,N,%u,%f,1",count+1,D_CH0);
		}
		if (msg1 !=NULL){
			strcat( msg,msg1);
		}
		Cumulative_MeasTime += Sampling_Interval_Time;
		count++;
	}
	mosquitto_publish(mosq, NULL, "test/t1", strlen(msg)+1, msg, 0, false);
	memset (msg, 0, MAXSIZE);
	MeasCount++;
    }while(!kbhit());

    /* Stop the asynchronous analog imput operation, and copy the A/D data to the buffer */
    err = UD_AI_AsyncClear(card, &AccessCnt);
    //printf("\n The # of A/D data that has been transfered: %d\n", AccessCnt);
    if(err != NoError)
    {
        printf("AI_AsyncClear Error: %d\n", err);
        UD_AI_AsyncClear(card, &AccessCnt);
        UD_Release_Card(card);
        fclose(w_file);
        exit(1);
    }
    fclose(w_file);
    UD_Release_Card(card);
    // printf("\nPress any key to exit...\n");
    // getch();
    return 0;
}
