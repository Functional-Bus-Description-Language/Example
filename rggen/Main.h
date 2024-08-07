#ifndef MAIN_H
#define MAIN_H
#include "stdint.h"
#define MAIN_SUBBLOCK_ADD_A_BIT_WIDTH 20
#define MAIN_SUBBLOCK_ADD_A_BIT_MASK 0xfffff
#define MAIN_SUBBLOCK_ADD_A_BIT_OFFSET 0
#define MAIN_SUBBLOCK_ADD_B_BIT_WIDTH 10
#define MAIN_SUBBLOCK_ADD_B_BIT_MASK 0x3ff
#define MAIN_SUBBLOCK_ADD_B_BIT_OFFSET 20
#define MAIN_SUBBLOCK_ADD_C_BIT_WIDTH 8
#define MAIN_SUBBLOCK_ADD_C_BIT_MASK 0xff
#define MAIN_SUBBLOCK_ADD_C_BIT_OFFSET 30
#define MAIN_SUBBLOCK_ADD_SUM_BIT_WIDTH 21
#define MAIN_SUBBLOCK_ADD_SUM_BIT_MASK 0x1fffff
#define MAIN_SUBBLOCK_ADD_SUM_BIT_OFFSET 38
#define MAIN_SUBBLOCK_ADD_BYTE_WIDTH 8
#define MAIN_SUBBLOCK_ADD_BYTE_SIZE 8
#define MAIN_SUBBLOCK_ADD_BYTE_OFFSET 0x0
#define MAIN_SUBBLOCK_SUM_STREAM_SUM_BIT_WIDTH 21
#define MAIN_SUBBLOCK_SUM_STREAM_SUM_BIT_MASK 0x1fffff
#define MAIN_SUBBLOCK_SUM_STREAM_SUM_BIT_OFFSET 0
#define MAIN_SUBBLOCK_SUM_STREAM_BYTE_WIDTH 4
#define MAIN_SUBBLOCK_SUM_STREAM_BYTE_SIZE 4
#define MAIN_SUBBLOCK_SUM_STREAM_BYTE_OFFSET 0x8
#define MAIN_C1_C1_BIT_WIDTH 7
#define MAIN_C1_C1_BIT_MASK 0x7f
#define MAIN_C1_C1_BIT_OFFSET 0
#define MAIN_C1_BYTE_WIDTH 4
#define MAIN_C1_BYTE_SIZE 4
#define MAIN_C1_BYTE_OFFSET 0xc
#define MAIN_C2_C2_BIT_WIDTH 9
#define MAIN_C2_C2_BIT_MASK 0x1ff
#define MAIN_C2_C2_BIT_OFFSET 0
#define MAIN_C2_BYTE_WIDTH 4
#define MAIN_C2_BYTE_SIZE 4
#define MAIN_C2_BYTE_OFFSET 0x10
#define MAIN_C3_C3_BIT_WIDTH 12
#define MAIN_C3_C3_BIT_MASK 0xfff
#define MAIN_C3_C3_BIT_OFFSET 0
#define MAIN_C3_BYTE_WIDTH 4
#define MAIN_C3_BYTE_SIZE 4
#define MAIN_C3_BYTE_OFFSET 0x14
#define MAIN_S1_S1_BIT_WIDTH 7
#define MAIN_S1_S1_BIT_MASK 0x7f
#define MAIN_S1_S1_BIT_OFFSET 0
#define MAIN_S1_BYTE_WIDTH 4
#define MAIN_S1_BYTE_SIZE 4
#define MAIN_S1_BYTE_OFFSET 0x18
#define MAIN_S2_S2_BIT_WIDTH 9
#define MAIN_S2_S2_BIT_MASK 0x1ff
#define MAIN_S2_S2_BIT_OFFSET 0
#define MAIN_S2_BYTE_WIDTH 4
#define MAIN_S2_BYTE_SIZE 4
#define MAIN_S2_BYTE_OFFSET 0x1c
#define MAIN_S3_S3_BIT_WIDTH 12
#define MAIN_S3_S3_BIT_MASK 0xfff
#define MAIN_S3_S3_BIT_OFFSET 0
#define MAIN_S3_BYTE_WIDTH 4
#define MAIN_S3_BYTE_SIZE 4
#define MAIN_S3_BYTE_OFFSET 0x20
#define MAIN_CA_C_BIT_WIDTH 8
#define MAIN_CA_C_BIT_MASK 0xff
#define MAIN_CA_C_BIT_OFFSET 0
#define MAIN_CA_BYTE_WIDTH 4
#define MAIN_CA_BYTE_SIZE 40
#define MAIN_CA_ARRAY_DIMENSION 1
#define MAIN_CA_ARRAY_SIZE_0 10
#define MAIN_CA_BYTE_OFFSET_0 0x24
#define MAIN_CA_BYTE_OFFSET_1 0x28
#define MAIN_CA_BYTE_OFFSET_2 0x2c
#define MAIN_CA_BYTE_OFFSET_3 0x30
#define MAIN_CA_BYTE_OFFSET_4 0x34
#define MAIN_CA_BYTE_OFFSET_5 0x38
#define MAIN_CA_BYTE_OFFSET_6 0x3c
#define MAIN_CA_BYTE_OFFSET_7 0x40
#define MAIN_CA_BYTE_OFFSET_8 0x44
#define MAIN_CA_BYTE_OFFSET_9 0x48
#define MAIN_SA_S_BIT_WIDTH 8
#define MAIN_SA_S_BIT_MASK 0xff
#define MAIN_SA_S_BIT_OFFSET 0
#define MAIN_SA_BYTE_WIDTH 4
#define MAIN_SA_BYTE_SIZE 40
#define MAIN_SA_ARRAY_DIMENSION 1
#define MAIN_SA_ARRAY_SIZE_0 10
#define MAIN_SA_BYTE_OFFSET_0 0x4c
#define MAIN_SA_BYTE_OFFSET_1 0x50
#define MAIN_SA_BYTE_OFFSET_2 0x54
#define MAIN_SA_BYTE_OFFSET_3 0x58
#define MAIN_SA_BYTE_OFFSET_4 0x5c
#define MAIN_SA_BYTE_OFFSET_5 0x60
#define MAIN_SA_BYTE_OFFSET_6 0x64
#define MAIN_SA_BYTE_OFFSET_7 0x68
#define MAIN_SA_BYTE_OFFSET_8 0x6c
#define MAIN_SA_BYTE_OFFSET_9 0x70
#define MAIN_COUNTER_VALUE_BIT_WIDTH 33
#define MAIN_COUNTER_VALUE_BIT_MASK 0x1ffffffff
#define MAIN_COUNTER_VALUE_BIT_OFFSET 0
#define MAIN_COUNTER_BYTE_WIDTH 8
#define MAIN_COUNTER_BYTE_SIZE 8
#define MAIN_COUNTER_BYTE_OFFSET 0x74
#define MAIN_MASK_MASK_BIT_WIDTH 16
#define MAIN_MASK_MASK_BIT_MASK 0xffff
#define MAIN_MASK_MASK_BIT_OFFSET 0
#define MAIN_MASK_BYTE_WIDTH 4
#define MAIN_MASK_BYTE_SIZE 4
#define MAIN_MASK_BYTE_OFFSET 0x7c
#define MAIN_VERSION_VERSION_BIT_WIDTH 24
#define MAIN_VERSION_VERSION_BIT_MASK 0xffffff
#define MAIN_VERSION_VERSION_BIT_OFFSET 0
#define MAIN_VERSION_BYTE_WIDTH 4
#define MAIN_VERSION_BYTE_SIZE 4
#define MAIN_VERSION_BYTE_OFFSET 0x80
typedef struct {
  uint64_t Add;
  uint32_t Sum_Stream;
} Main_Subblock_t;
typedef struct {
  Main_Subblock_t Subblock;
  uint32_t C1;
  uint32_t C2;
  uint32_t C3;
  uint32_t S1;
  uint32_t S2;
  uint32_t S3;
  uint32_t CA[10];
  uint32_t SA[10];
  uint64_t Counter;
  uint32_t Mask;
  uint32_t Version;
  uint32_t __reserved_0x84;
  uint32_t __reserved_0x88;
  uint32_t __reserved_0x8c;
  uint32_t __reserved_0x90;
  uint32_t __reserved_0x94;
  uint32_t __reserved_0x98;
  uint32_t __reserved_0x9c;
  uint32_t __reserved_0xa0;
  uint32_t __reserved_0xa4;
  uint32_t __reserved_0xa8;
  uint32_t __reserved_0xac;
  uint32_t __reserved_0xb0;
  uint32_t __reserved_0xb4;
  uint32_t __reserved_0xb8;
  uint32_t __reserved_0xbc;
  uint32_t __reserved_0xc0;
  uint32_t __reserved_0xc4;
  uint32_t __reserved_0xc8;
  uint32_t __reserved_0xcc;
  uint32_t __reserved_0xd0;
  uint32_t __reserved_0xd4;
  uint32_t __reserved_0xd8;
  uint32_t __reserved_0xdc;
  uint32_t __reserved_0xe0;
  uint32_t __reserved_0xe4;
  uint32_t __reserved_0xe8;
  uint32_t __reserved_0xec;
  uint32_t __reserved_0xf0;
  uint32_t __reserved_0xf4;
  uint32_t __reserved_0xf8;
  uint32_t __reserved_0xfc;
} Main_t;
#endif
