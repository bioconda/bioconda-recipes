#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  mv bin/porfast_osx $PREFIX/bin/porfast
  chmod +x $PREFIX/bin/porfast
else
  mkdir -p $PREFIX/bin
  nimble install -y --verbose argparse
  nim c --threads:on -p:lib --opt:speed -o:$PREFIX/bin/porfast src/porfast.nim
fi

