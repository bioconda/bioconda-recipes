#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
make

cp RepeatScout build_lmer_table ${PREFIX}/bin
