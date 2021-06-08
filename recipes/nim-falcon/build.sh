#!/bin/bash
set -eu -o pipefail
set -vx

echo $(pwd)
ls -larth
ls -larth bin/

#mkdir -p $PREFIX
chmod -R a+x bin
cp -Rf bin ${PREFIX}
