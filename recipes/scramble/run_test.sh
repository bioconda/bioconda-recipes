#!/usr/bin/env bash

cluster_identifier validation/test.bam | diff - validation/test.clusters.txt

scramble.sh --cluster-file "$(pwd)/validation/test.clusters.txt"\
  --out-name "$(pwd)/validation/test_conda"\
  --ref "$(pwd)/validation/test.fa"\
  --eval-dels\
  --eval-meis

diff validation/test_conda_MEIs.txt validation/test_MEIs.txt
diff validation/test_conda_PredictedDeletions.txt validation/test_PredictedDeletions.txt
diff -I '^##reference=' validation/test_conda.vcf validation/test.vcf
