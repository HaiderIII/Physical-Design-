#!/usr/bin/env bash

OPENSTA_BIN="$HOME/eda_tools/OpenSTA/build/sta"

if [ ! -x "$OPENSTA_BIN" ]; then
  echo "ERROR: opensta binary not found at $OPENSTA_BIN"
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: ./run_opensta.sh <run.tcl>"
  exit 1
fi

"$OPENSTA_BIN" "$1"
