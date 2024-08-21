// Generated by PeakRDL-cheader - A free and open-source header generator
//  https://github.com/SystemRDL/PeakRDL-cheader

#ifndef BUS_H
#define BUS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <assert.h>

// Reg - Main::C
#define MAIN__C__C1_bm 0x7f
#define MAIN__C__C1_bp 0
#define MAIN__C__C1_bw 7
#define MAIN__C__C2_bm 0xff80
#define MAIN__C__C2_bp 7
#define MAIN__C__C2_bw 9
#define MAIN__C__C3_bm 0xfff0000
#define MAIN__C__C3_bp 16
#define MAIN__C__C3_bw 12

// Reg - Main::S
#define MAIN__S__S1_bm 0x7f
#define MAIN__S__S1_bp 0
#define MAIN__S__S1_bw 7
#define MAIN__S__S2_bm 0xff80
#define MAIN__S__S2_bp 7
#define MAIN__S__S2_bw 9
#define MAIN__S__S3_bm 0xfff0000
#define MAIN__S__S3_bp 16
#define MAIN__S__S3_bw 12

// Reg - Main::CA
#define MAIN__CA__C_bm 0xff
#define MAIN__CA__C_bp 0
#define MAIN__CA__C_bw 8

// Reg - Main::SA
#define MAIN__SA__C_bm 0xff
#define MAIN__SA__C_bp 0
#define MAIN__SA__C_bw 8

// Reg - Main::Counter0
#define MAIN__COUNTER0__VALUE_bm 0xffffffff
#define MAIN__COUNTER0__VALUE_bp 0
#define MAIN__COUNTER0__VALUE_bw 32

// Reg - Main::Counter1
#define MAIN__COUNTER1__VALUE_bm 0x1
#define MAIN__COUNTER1__VALUE_bp 0
#define MAIN__COUNTER1__VALUE_bw 1

// Addrmap - Main
typedef struct __attribute__ ((__packed__)) {
    uint32_t C;
    uint32_t S;
    uint8_t CA[10];
    uint8_t SA[10];
    uint32_t Counter0;
    uint8_t Counter1;
} Main_t;


static_assert(sizeof(Main_t) == 0x21, "Packing error");

#ifdef __cplusplus
}
#endif

#endif /* BUS_H */