#!/bin/sh

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi
 
 
export LD_LIBRARY_PATH=$PREFIX/lib

nimble install -y --verbose
mkdir -p $PREFIX/bin

for BIN in $(ls src/* | grep -v '\.');
do
  chmod a+x src/${BIN}
  cp ${BIN} "$PREFIX"/bin/${BIN}
done