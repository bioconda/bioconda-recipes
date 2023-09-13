#!/bin/sh
set -x -e

mkdir -p ${PREFIX}/bin

#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac

./autogen.sh
export PYTHON_NOVERSION_CHECK="3.7.0"
./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
make
make install

# This directory isn't needed and confuses conda
rm -rf $PREFIX/mkspecs

cd ${PREFIX}/lib
# Something is creating a symlink from ${PREFIX}/lib/\n
find . -type l -not -name "??*" -ls -delete
