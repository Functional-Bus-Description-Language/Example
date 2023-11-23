#!/bin/bash
set -e

LOGDIR="/tmp/fbdl-example/"
PYTHON_FILE="../../../test_fbdl.py"

export PYTHONPATH="$PYTHONPATH:$PWD/../../../autogen/fbdl/python/"

mkdir -p $LOGDIR
if [ ! -f "$PYTHON_FILE" ]; then
	>&2 echo "$PYTHON_FILE not found"
	exit 1
fi
python3 $PYTHON_FILE \
	> "$LOGDIR/fbdl.log" 2>&1 &
