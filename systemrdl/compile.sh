#!/bin/bash
set -e
peakrdl c-header bus.rdl -o bus.h
peakrdl regblock bus.rdl -o sv
