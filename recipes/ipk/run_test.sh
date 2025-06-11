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
ipk-dna 2>&1 | grep "the option '--ar-binary' is required"
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

# D
echo "test D"
ipk.py build --help
if [ $? -ne 0 ]; then
  echo "failed"
  PASS=false
fi

# E
# test files cannot be retrieved via meta.yaml (field test:source)
# because git-lfs is not available in the github tarball release
# we need to download them manually
#echo "test E"

#wget -O reference.fasta https://github.com/phylo42/IPK/raw/main/tests/data/neotrop/reference.fasta 
#wget -O tree.rooted.newick https://github.com/phylo42/IPK/raw/main/tests/data/neotrop/tree.rooted.newick
#test -s reference.fasta
#test -s tree.rooted.newick
#mkdir -p tests_output
#ipk.py build -r reference.fasta -t tree.rooted.newick -m GTR -k 7 --omega 2.0 -u 1.0 -b $(which raxml-ng) -w tests_output
#if [ $? -ne 0 ]; then
#  echo "failed"
#  PASS=false
#fi

#ls tests_output
#echo $PASS

# F
#echo "test F"
#if [ ! -s tests_output/DB_k7_o2.0.rps ]; then
#  echo "failed"
#  PASS=false
#fi

if [ "$PASS" = false ]; then
  echo "At least 1 test failed !"
  exit 1
fi
