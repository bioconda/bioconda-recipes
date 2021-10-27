#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  export HOME=`pwd`
fi

mkdir -p $PREFIX/bin
#nimble install -y --verbose terminaltables docopt zip uuids
#nim c -d:useLibzipSrc -d:release -p:lib/yaml --opt:speed -o:$PREFIX/bin/qax src/qax.nim

nimble build -y
mv ./bin/qax "$PREFIX"/bin/
