#!/bin/bash

make all

binaries="\
finale \
pedstats \
prelude \
qtdt \
"

for i in $binaries; do mv $SRC_DIR/executables/$i $PRFIX/bin/$i; done