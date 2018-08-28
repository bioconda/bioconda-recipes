#!/bin/bash
make tgs
binaries="\
TransGeneScan \
run_TransGeneScan.pl \
processFragOut.py \
post_process.pl \
FGS_gff.py \
"

for i in $binaries; do cp $i $PREFIX/bin/$i; done
chmod +x $PREFIX/bin/TransGeneScan 