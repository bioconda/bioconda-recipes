#!/bin/sh

export BRANCH=v0.19.0
export PATH="nim-$BRANCH/bin/nim/bin:${PATH:+:$PATH}"
export LD=$CC
bash ./scripts/install.sh
export PATH="nim-$BRANCH/bin:${PATH:+:$PATH}"
nim c -d:release -r mosdepth.nim
mkdir -p $PREFIX/bin
chmod a+x mosdepth
cp mosdepth $PREFIX/bin/mosdepth
