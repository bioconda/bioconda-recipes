#!/usr/bin/env bash

PASS=true

# A
echo "test A"
command -v epik-dna
if [ $? -ne 0  ]; then
  echo "failed"
  PASS=false
fi

# B
echo "test B"
command -v epik-aa
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

# C
echo "test C"
epik-dna 2>&1 | grep "Evolutionary Placement with Informative K-mers"
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

#D
echo "test D"
epik.py place --help
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

