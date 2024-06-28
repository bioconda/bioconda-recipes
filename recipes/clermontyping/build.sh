#!/usr/bin/env bash

set -xe

cp $SRC_DIR/clermonTyping.sh ${PREFIX}
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/bin
cp $SRC_DIR/bin/* ${PREFIX}/bin/bin