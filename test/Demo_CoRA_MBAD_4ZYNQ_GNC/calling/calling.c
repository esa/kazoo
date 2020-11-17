/* User code: This file will not be overwritten by TASTE. */

#include "calling.h"
#include <string.h>
#include <stdio.h>

char p_szGlobalState[10] = "modeX";

#define FPGA_READY              "ready"
#define FPGA_RECONFIGURING      "reconfiguring"
#define FPGA_ERROR              "error"
#define FPGA_DISABLED           "disabled"

// For each HWSW Function Block a global variable must be created with name "globalFpgaStatus_<Function Block's name>".
// This variable will host at any time the current HW status associated with the respective Function Block.
// This status shall be updated by the HW reconfiguration manager commanding of the FPGA and FPGA status check,
// and can be one of: FPGA_READY, FPGA_RECONFIGURING, FPGA_ERROR, FPGA_DISABLED.
// Status is kept per Function Block and not for the full FPGA, to accommodate for future work on partial reconfiguration of the HW accelerator.
char globalFpgaStatus_gnc[20] = FPGA_READY;

//uncomment the following define to print debug level info
//#define DEBUG_RECONF

void calling_startup()
{
    /* Write your initialization code here,
       but do not make any call to a required interface. */
    printf("\n[calling_startup] Starting up ...\n");

}

void calling_PI_changeMode()
{
    char new_config[10] = "";
    
    if (strcmp(p_szGlobalState, "modeX") == 0) {
        strcpy(new_config, "modeA");
    }else{
        if (strcmp(p_szGlobalState, "modeA") == 0) {
            strcpy(new_config, "modeC");
        }else{
            strcpy(new_config, "modeX");
        }
    }
    printf("[calling_PI_changeMode] Initiating mode change %s => %s ... \n", p_szGlobalState, new_config);
    
    strcpy(p_szGlobalState, new_config);
    
    printf("[calling_PI_changeMode] Current mode is %s\n", p_szGlobalState);
}

void calling_PI_pulse()
{
    printf("\n[calling_PI_pulse] Current mode is %s\n", p_szGlobalState);

    static asn1SccSeq3 in1 = {0,0,0};
    static asn1SccSeq3 in2 = {1,1,1};
    static asn1SccSeq4 in3 = {2,2,2,2};
    static asn1SccIn_Nested inn = {{3,3,3,3}, {4,4,4}};

    asn1SccSeqout out1 = {0,0,0,0,0,0,0,0};
    asn1SccOut_Nested outn = {{0,0,0,0,0,0,0}};
   
    printf("[calling_PI_pulse] Calling 'do_something'\n");
    calling_RI_do_something(&in1, &in2, &in3, &out1, &inn, &outn);
    
    printf("[calling_PI_pulse] Sent: %lld %lld %lld\n", in1.arr[0], in1.arr[1], in1.arr[2]);
    printf("[calling_PI_pulse] Sent: %lld %lld %lld\n", in2.arr[0], in2.arr[1], in2.arr[2]);
    printf("[calling_PI_pulse] Sent: %lld %lld %lld %lld\n", in3.arr[0], in3.arr[1], in3.arr[2], in3.arr[3]);
    printf("[calling_PI_pulse] Sent: {%lld %lld %lld %lld - %lld %lld %lld}\n\n", inn.inest_a.arr[0], inn.inest_a.arr[1], inn.inest_a.arr[2], inn.inest_a.arr[3],  inn.inest_b.arr[0], inn.inest_b.arr[1], inn.inest_b.arr[2]);

    printf("[calling_PI_pulse] Received: %lld %lld %lld %lld %lld %lld %lld %lld\n", out1.arr[0], out1.arr[1], out1.arr[2], out1.arr[3], out1.arr[4], out1.arr[5], out1.arr[6], out1.arr[7]);
    printf("[calling_PI_pulse] Received: {%lld %lld %lld %lld %lld %lld %lld}\n", outn.onest_a.arr[0], outn.onest_a.arr[1], outn.onest_a.arr[2], outn.onest_a.arr[3], outn.onest_a.arr[4], outn.onest_a.arr[5], outn.onest_a.arr[6]);

    in1.arr[0]++; in1.arr[1]++; in1.arr[2]++;
    in2.arr[0]++; in2.arr[1]++; in2.arr[2]++;
    in3.arr[0]++; in3.arr[1]++; in3.arr[2]++; in3.arr[3]++;
    inn.inest_a.arr[0]++; inn.inest_a.arr[1]++; inn.inest_a.arr[2]++; inn.inest_a.arr[3]++; inn.inest_b.arr[0]++; inn.inest_b.arr[1]++; inn.inest_b.arr[2]++;
}

