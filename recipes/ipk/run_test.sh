#!/usr/bin/env bash

pwd
mkdir -p tests_output
ls
ls tests

PASS=true

# A
test -f $(which ipk-dna)
if [ $? -ne 0  ]; then
  echo "test A:failed"
  PASS=false
fi

# B
test -f $(which ipk-aa)
if [ $? -ne 0 ]; then
  echo "test B:failed"
  PASS=false
fi

# C
#echo $(ipk-dna) | grep "the option '--ar-binary' is required"
#if [ $? -eq 0 ]; then
#  echo "test C:failed"
#  PASS=false
#fi

# D
ipk.py build --help
if [ $? -ne 0 ]; then
  echo "test D:failed"
  PASS=false
fi

# E
# reference files were copied via meta.yaml instructions
ipk.py build -r reference.fasta -t tree.rooted.newick -m GTR -k 7 --omega 2.0 -u 1.0 -b raxml-ng -w tests_output
if [ $? -ne 0 ]; then
  echo "test E:failed"
  PASS=false
fi

ls
ls tests_output

# F
test -f tests_output/DB_k7_o2.0.rps
if [ $? -ne 0 ]; then
  echo "test F:failed"
  PASS=false
fi

exit 0
