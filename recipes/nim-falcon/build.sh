#!/bin/bash
set -eu -o pipefail

# Build script based off of mosdepth/hts-nim-tools build.

echo $PATH

set -vx

echo $(pwd)
ls -larth

#mkdir -p $PREFIX
cp -Rf bin ${PREFIX}
chmod -R a+x ${PREFIX}/bin
