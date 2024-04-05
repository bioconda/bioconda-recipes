#!/bin/bash
set -eu -o pipefail

echo $PATH

set -vx

echo $(pwd)
ls -larth
ls -larth bin/

#mkdir -p $PREFIX
chmod --recursive a+x bin/
cp -Rf bin ${PREFIX}
#chmod -R a+x ${PREFIX}/bin

cp -Rf etc ${PREFIX}
