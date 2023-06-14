#!/bin/bash

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable -print | grep diann)
DIANN_DIR=$(dirname $DIANN_PATH)

find $DIANN_DIR -type f -exec install -m 0755 {} $PREFIX/bin/ \;