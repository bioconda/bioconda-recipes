#!/bin/bash
set -euo pipefail

TESTDATA="https://harvest.readthedocs.io/en/latest/_downloads/mers49.tar.gz"
curl -O $TESTDATA >/dev/null
tar -xvf mers49.tar.gz >/dev/null

parsnp -V >/dev/null
parsnp -g ./ref/EMC_2012.gbk -d ./mers49 -C 1000 -c -o test >/dev/null

