#!/bin/sh
set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi
 
 
export LD_LIBRARY_PATH=$PREFIX/lib

nimble install -y --verbose
mkdir -p $PREFIX/bin

pwd
ls -l bin/* 

for BIN in $(ls bin/* | grep -v '\.');
do
  if [ ! -e "$PREFIX"/bin/${BIN} ]; then
	chmod a+x ${BIN}
    cp ${BIN} "$PREFIX"/bin/${BIN}
  fi
done