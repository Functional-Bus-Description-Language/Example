#ifndef _VFBDB_Main_H_

#include "vfbdb.h"

extern const uint32_t vfbdb_Main_ID;
int vfbdb_Main_ID_read(const vfbdb_iface_t * const iface, uint32_t * const data);

int vfbdb_Main_S1_read(const vfbdb_iface_t * const iface, uint8_t * const data);

int vfbdb_Main_S2_read(const vfbdb_iface_t * const iface, uint16_t * const data);

int vfbdb_Main_S3_read(const vfbdb_iface_t * const iface, uint16_t * const data);

int vfbdb_Main_C1_read(const vfbdb_iface_t * const iface, uint8_t * const data);
int vfbdb_Main_C1_write(const vfbdb_iface_t * const iface, uint8_t const data);

int vfbdb_Main_C2_read(const vfbdb_iface_t * const iface, uint16_t * const data);
int vfbdb_Main_C2_write(const vfbdb_iface_t * const iface, uint16_t const data);

int vfbdb_Main_C3_read(const vfbdb_iface_t * const iface, uint16_t * const data);
int vfbdb_Main_C3_write(const vfbdb_iface_t * const iface, uint16_t const data);

#endif // _VFBDB_Main_H_
