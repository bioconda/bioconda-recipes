#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin
chmod 777 genblast*
cp genblast_v138 $PREFIX/bin/genblastG
