#!/bin/sh
set -x -e

cd src
make


for name in bin/* ; do
  ln -s $name ${PREFIX}/bin/$(basename $name)
done
