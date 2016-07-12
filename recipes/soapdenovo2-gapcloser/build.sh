#!/bin/sh
set -x -e


mkdir -p $PREFIX/bin

chmod u+x GapCloser
cp GapCloser $PREFIX/bin

