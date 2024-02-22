#!/usr/bin/env bash

PASS=true

# A
echo "test A"
test -f $(which ipk-dna)
if [ $? -ne 0  ]; then
  echo "failed"
  PASS=false
fi

# B
echo "test B"
test -f $(which ipk-aa)
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

# C
#echo $(ipk-dna) | grep "the option '--ar-binary' is required"
#if [ $? -eq 0 ]; then
#  echo "test C:failed"
#  PASS=false
#fi

# D
echo "test D"
ipk.py build --help
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

# E
# reference files were copied via meta.yaml instructions, keeping git directory structure
echo "test E"
RALIGN=tests/data/neotrop/reference.fasta
RTREE=tests/data/neotrop/tree.rooted.newick
mkdir -p tests_output
ipk.py build -r $RALIGN -t $RTREE -m GTR -k 7 --omega 2.0 -u 1.0 -b $(which raxml-ng) -w tests_output
ls tests_output

#if [ $? -ne 0 ]; then
#  echo "failed"
#  PASS=false
#fi

#cat log
#ls tests_output
#echo $PASS

# F
#echo "test F"
#test -f tests_output/DB_k7_o2.0.rps
#if [ $? -ne 0 ]; then
#  echo "failed"
#  PASS=false
#fi

#if [ "$PASS" = false ]; then
#  echo "some test failed"
#  exit 1
#fi
