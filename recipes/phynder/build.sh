#!/bin/bash
set -x
set +e

export CPATH=${PREFIX}/include
export HTSDIR=${PREFIX}/lib/

make
make install
