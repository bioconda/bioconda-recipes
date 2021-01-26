#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi

mkdir -p $PREFIX/bin

nimble install -y --verbose argparse docopt terminaltables
nim c --threads:on -p:lib --opt:speed -d:release -o:$PREFIX/bin/seqfu src/sfu.nim


for SOURCE in src/fu_*.nim;
do
	NAME=$(basename $SOURCE | sed 's/_/-/'  |cut -f1 -d.)
	echo "$SOURCE -> $NAME"
	nim c -p:lib --opt:speed -d:release -o:"$PREFIX/bin/${NAME}" "$SOURCE" || true
done
