#!/bin/bash

# Ensure the script is executable
test -x ${PREFIX}/bin/PoolSNP.sh

# Run PoolSNP.sh with a minimal set of parameters to ensure it executes
bash ${PREFIX}/bin/PoolSNP.sh \
  mpileup="${PREFIX}/share/PoolSNP/TestData/test.mpileup" \
  reference="${PREFIX}/share/PoolSNP/TestData/test.fa" \
  names=Sample1,Sample2 \
  max-cov=0.7 \
  min-cov=4 \
  min-count=4 \
  min-freq=0.01 \
  miss-frac=0.5 \
  jobs=4 \
  badsites=1 \
  allsites=1 \
  output=${PREFIX}/share/PoolSNP/TestResult/test

# Optionally, check the output file to ensure it was created
test -f ${PREFIX}/share/PoolSNP/TestResult/test.vcf.gz