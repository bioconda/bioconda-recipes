#!/bin/sh
set -x -e


mkdir -p $PREFIX/bin

cp GapCloser $PREFIX/bin


chmod 777 GapCloser
./GapCloser
