#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/bin
cp $SRC_DIR/clermonTyping.sh ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/bin
cp $SRC_DIR/bin/* ${PREFIX}/bin/bin