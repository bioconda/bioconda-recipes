#!/bin/bash
set -x -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/bin

#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac
sed -i.bak 's|'3.5'|'3.10'|' configure.ac
rm -rf *.bak

./autogen.sh
#export PYTHON_NOVERSION_CHECK="3.10.0"
./configure --prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  PYTHON="${PYTHON}" --enable-silent-rules --disable-dependency-tracking \
  --disable-option-checking
make -j"${CPU_COUNT}"
make install

# This directory isn't needed and confuses conda
rm -rf $PREFIX/mkspecs

cd ${PREFIX}/lib
# Something is creating a symlink from ${PREFIX}/lib/\n
find . -type l -not -name "??*" -ls -delete
