#!/bin/sh

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi
 
 
export LD_LIBRARY_PATH=$PREFIX/lib

nimble install -y --verbose
mkdir -p $PREFIX/bin

for BIN in $(ls src/* | grep -v '\.');
do
  if [ ! -e "$PREFIX"/bin/${BIN} ]; then
	chmod a+x ${BIN}
    cp ${BIN} "$PREFIX"/bin/${BIN}
  fi
done