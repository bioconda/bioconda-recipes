#!/bin/sh

export BRANCH=v0.19.0
export PATH="nim-$BRANCH/bin/nim/bin:${PATH:+:$PATH}"
export LD=$CC
sed 's|sh build.sh|sed -i "s/gcc/${CC}/g" build.sh \&\& sh build.sh|g' ./scripts/build.sh
bash ./scripts/build.sh
export PATH="nim-$BRANCH/bin:${PATH:+:$PATH}"
nim c -d:release -r src/somalier.nim
mkdir -p $PREFIX/bin
chmod a+x somalier
cp somalier $PREFIX/bin/somalier
