#!/usr/bin/env bash

PASS=true

# A
echo "test A"
command -v ipk-dna
if [ $? -ne 0  ]; then
  echo "failed"
  PASS=false
fi

# B
echo "test B"
command -v ipk-aa
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

# C
echo "test C"
ipk.py build --help
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

if [ "$PASS" = false ]; then
  echo "At least 1 test failed !"
  exit 1
fi
