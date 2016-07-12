#!/bin/sh
set -x -e


mkdir -p $PREFIX/bin

cp GapCloser $PREFIX/bin

chmod u+x GapCloser
./GapCloser
