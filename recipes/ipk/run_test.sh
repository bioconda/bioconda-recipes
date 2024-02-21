#!/usr/bin/env bash

echo $(pwd)

mkdir -p tests_output

echo $(ls -lh)

# A
test -f $(which ipk-dna)
if [ $? -eq 0 ]; then
  echo "test A:failed"
  exit 1
fi

# B
test -f $(which ipk-aa)
if [ $? -eq 0 ]; then
  echo "test B:failed"
  exit 1
fi

# C
#echo $(ipk-dna) | grep "the option '--ar-binary' is required"
#if [ $? -eq 0 ]; then
#  echo "test C:failed"
#  exit 1
#fi

# D
ipk.py build --help
if [ $? -eq 0 ]; then
  echo "test D:failed"
  exit 1
fi

# E
# reference files were copied via meta.yaml instructions
ipk.py build -r reference.fasta -t tree.rooted.newick -m GTR -k 7 --omega 2.0 -u 1.0 -b raxml-ng -w tests_output
if [ $? -eq 0 ]; then
  echo "test E:failed"
  exit 1
fi

echo $(ls -lh)

# F
test -f tests_output/DB_k7_o2.0.rps
if [ $? -eq 0 ]; then
  echo "test F:failed"
  exit 1
fi

exit 0
