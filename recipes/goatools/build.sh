#!/bin/bash

$PYTHON setup.py install

binaries="\
scripts/find_enrichment.py \
scripts/map_to_slim.py \
scripts/plot_go_term.py
"

mkdir -p $PREFIX/bin/
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/; done
