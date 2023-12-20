#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi
mkdir -p $PREFIX/bin
nimble install -y --verbose argparse
nim c --threads:on -p:lib --opt:speed -o:$PREFIX/bin/porfast src/porfast.nim
