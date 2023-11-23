#include "vfbdb.h"

const uint32_t vfbdb_Main_ID = 0xe2c709ee;
int vfbdb_Main_ID_read(const vfbdb_iface_t * const iface, uint32_t * const data) {
	return iface->read(0, data);
};

int vfbdb_Main_S1_read(const vfbdb_iface_t * const iface, uint8_t * const data) {
	uint32_t aux;
	const int err = iface->read(6, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x7f;
	return 0;
};

int vfbdb_Main_S2_read(const vfbdb_iface_t * const iface, uint16_t * const data) {
	uint32_t aux;
	const int err = iface->read(5, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x1ff;
	return 0;
};

int vfbdb_Main_S3_read(const vfbdb_iface_t * const iface, uint16_t * const data) {
	uint32_t aux;
	const int err = iface->read(4, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0xfff;
	return 0;
};

int vfbdb_Main_C1_read(const vfbdb_iface_t * const iface, uint8_t * const data) {
	uint32_t aux;
	const int err = iface->read(1, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x7f;
	return 0;
};

int vfbdb_Main_C1_write(const vfbdb_iface_t * const iface, uint8_t const data) {
	return iface->write(1, (data << 0));
 };
int vfbdb_Main_C2_read(const vfbdb_iface_t * const iface, uint16_t * const data) {
	uint32_t aux;
	const int err = iface->read(2, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0x1ff;
	return 0;
};

int vfbdb_Main_C2_write(const vfbdb_iface_t * const iface, uint16_t const data) {
	return iface->write(2, (data << 0));
 };
int vfbdb_Main_C3_read(const vfbdb_iface_t * const iface, uint16_t * const data) {
	uint32_t aux;
	const int err = iface->read(3, &aux);
	if (err)
		return err;
	*data = (aux >> 0) & 0xfff;
	return 0;
};

int vfbdb_Main_C3_write(const vfbdb_iface_t * const iface, uint16_t const data) {
	return iface->write(3, (data << 0));
 };
