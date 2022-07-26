#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  export HOME=`pwd`
fi

mkdir -p "$PREFIX"/bin

chmod +x graphanalyzer.py
mv graphanalyzer.py "$PREFIX"/bin/
