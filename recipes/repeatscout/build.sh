#!/bin/sh
set -x -e
make

cp RepeatScout build_lmer_table ${PREFIX}/bin
