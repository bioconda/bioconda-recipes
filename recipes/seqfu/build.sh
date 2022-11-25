#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  export HOME=`pwd`
fi

mkdir -p "$PREFIX"/bin

echo "## Automatic build"
nimble build -y --verbose 
./bin/seqfu version || true

if [[ -d scripts ]]; then
  echo "## Copying utils"
  chmod +x scripts/*
  cp scripts/* bin/
fi

echo "## Current dir: $(pwd)"
mv bin/* "$PREFIX"/bin/


echo "## List files in \$PREFIX/bin:"
ls -ltr "$PREFIX"/bin/
 
