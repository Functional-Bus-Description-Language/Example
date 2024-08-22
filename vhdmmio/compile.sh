#!/bin/sh
set -e
vhdmmio main.yaml -V vhdl
vhdmmio subblock.yaml -V vhdl
