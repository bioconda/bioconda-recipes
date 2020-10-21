#!/bin/bash
 
declare -a tools=("genoStats" "pileupCaller" "vcf2eigenstrat")
 
mkdir -p $PREFIX/bin
 
for t in "${tools[@]}"
do
  mv ${t} $PREFIX/bin/
done

