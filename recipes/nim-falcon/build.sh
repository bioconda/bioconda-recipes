#!/bin/bash
set -eu -o pipefail

echo $PATH

set -vx

echo $(pwd)
ls -larth

#mkdir -p $PREFIX
cp -Rf bin ${PREFIX}
chmod -R a+x ${PREFIX}/bin
