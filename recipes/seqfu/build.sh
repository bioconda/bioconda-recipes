#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi

mkdir -p $PREFIX/bin

echo " * Attempt automatic build"
nimble build -y --verbose || true

pwd
ls -ltr $PREFIX/bin/

echo " * Legacy procedure"
nimble install -y --verbose argparse docopt terminaltables readfq iterutils

mkdir -p "${PREFIX}/bin"
mv bin/* "${PREFIX}/bin/"
