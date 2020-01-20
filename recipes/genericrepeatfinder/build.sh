#!/bin/sh
set -x -e

cd src
${CC} -print-search-dirs
unset COMPILER_PATH
${CC} -print-search-dirs
make CC=$CC


for name in bin/* ; do
  ln -s $name ${PREFIX}/bin/$(basename $name)
done
