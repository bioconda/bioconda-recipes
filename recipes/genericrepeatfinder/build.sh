#!/bin/sh
set -x -e

cd src
make CC=$GXX


for name in bin/* ; do
  ln -s $name ${PREFIX}/bin/$(basename $name)
done
