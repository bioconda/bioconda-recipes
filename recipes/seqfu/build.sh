#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  export HOME=`pwd`
fi

mkdir -p $PREFIX/bin

echo " * Attempt automatic build"
nimble build -y --verbose 

pwd
ls -ltr $PREFIX/bin/
 
