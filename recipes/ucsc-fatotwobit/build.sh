#!/bin/bash

# linux -- build
if [[ -z "$OSX_ARCH" ]]; then
  export MACHTYPE=x86_64
  export BINDIR=$(pwd)/bin
  mkdir -p $BINDIR
  (cd kent/src/lib && make)
  (cd kent/src/jkOwnLib && make)
  (cd kent/src/hg/lib && make)
  (cd kent/src/htslib && make)
  (cd kent/src/utils/faToTwoBit && make)
  mkdir -p $PREFIX/bin
  cp bin/faToTwoBit $PREFIX/bin
  chmod +x $PREFIX/bin/faToTwoBit
# osx -- use binary
else
  mkdir -p $PREFIX/bin
  cp faToTwoBit $PREFIX/bin
  chmod +x $PREFIX/bin/faToTwoBit
fi
