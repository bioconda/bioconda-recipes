#!/bin/bash
set -euo pipefail

TESTDATA="https://harvest.readthedocs.io/en/latest/_downloads/mers49.tar.gz"
curl -O $TESTDATA >/dev/null
tar -xvf mers49.tar.gz >/dev/null

rm mers49/._* -f

parsnp -V >/dev/null
parsnp -g ./ref/EMC_2012.gbk -d ./mers49/*.fna -C 1000 -c -o test --verbose --use-fasttree >/dev/null

parsnp -r ! -d ./mers49/*.fna -o test --verbose  >/dev/null
