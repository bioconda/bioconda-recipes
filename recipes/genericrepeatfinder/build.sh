#!/bin/sh
set -x -e

cd src
make CC=$GXX

cd ..
mkdir -p ${PREFIX}/bin
for name in bin/* ; do
  cp $name ${PREFIX}/bin/$(basename $name)
  chmod a+x ${PREFIX}/bin/$(basename $name)
done
