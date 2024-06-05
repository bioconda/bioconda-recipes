#!/bin/bash

set -xe

cd $PREFIX
cmake $SRC_DIR
make -j ${CPU_COUNT}
