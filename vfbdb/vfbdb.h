#ifndef _VFBDB_VFBDB_H_
#define _VFBDB_VFBDB_H_

#include <stddef.h>
#include <stdint.h>

typedef struct {
	int (*read)(const uint8_t addr, uint32_t * const data);
	int (*write)(const uint8_t addr, const uint32_t data);
	int (*readb)(const uint8_t addr, uint32_t * buf, size_t count);
	int (*writeb)(const uint8_t addr, const uint32_t * buf, size_t count);
} vfbdb_iface_t;

#define vfbdb_read(elem, data) (vfbdb_ ## elem ## _read(VFBDB_IFACE, data))
#define vfbdb_write(elem, data) (vfbdb_ ## elem ## _write(VFBDB_IFACE, data))

#ifdef VFBDB_SHORT_MACROS
	#undef vfbdb_read
	#undef vfbdb_write
	#define read(elem, data) (vfbdb_ ## elem ## _read(VFBDB_IFACE, data))
	#define write(elem, data) (vfbdb_ ## elem ## _write(VFBDB_IFACE, data))
#endif

#endif // _VFBDB_VFBDB_H_
