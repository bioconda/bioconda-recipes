#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin
chmod 777 genblast_v1.0.4
cp genblast_v1.0.4 $PREFIX/bin/genblastA
