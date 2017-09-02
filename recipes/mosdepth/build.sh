#!/bin/sh

export BRANCH=master
export PATH="nim-$BRANCH/bin/nim/bin:${PATH:+:$PATH}"
bash ./scripts/install.sh
export PATH="nim-$BRANCH/bin:${PATH:+:$PATH}"
nim c -r mosdepth.nim
mkdir -p $PREFIX/bin
chmod a+x mosdepth
cp mosdepth $PREFIX/bin/mosdepth
