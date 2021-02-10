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

echo " * Build SeqFu"
nim c --threads:on -p:lib --opt:speed -d:release -o:$PREFIX/bin/seqfu src/sfu.nim


for SOURCE in src/fu_*.nim;
do
	NAME=$(basename "${SOURCE%.nim}" | sed 's/_/-/' )
    THREADS=""
    echo " * Build $NAME"
    CHECK_THREADS=$(grep thread "$SOURCE" | wc -l || true )
	if [[ "$CHECK_THREADS" -ne 0 ]]; then
	    THREADS=" --threads:on "
	fi
	nim c $THREADS -p:lib --opt:speed -d:release -o:"$PREFIX/bin/${NAME}" "$SOURCE" || true
done
