#!/bin/bash
set -x -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-unused-but-set-variable -Wno-vla-cxx-extension -Wno-sizeof-pointer-div"
export LC_ALL="en_US.UTF-8"
export PYTHONPATH="${SP_DIR}"

mkdir -p ${PREFIX}/bin

# https://stackoverflow.com/questions/22401500/autoconf-error-possibly-undefined-macro-ac-libobj
cd deps/jellyfish-2.2.0 && aclocal && cd ../../

#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac
sed -i.bak 's|'3.5'|'3.10'|' configure.ac
rm -rf *.bak

./autogen.sh
export PYTHON_NOVERSION_CHECK="${PY_VER}"
./configure --prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  PYTHON="${PYTHON}" PYTHON_VERSION="${PY_VER}" LIBS="-lz -lboost_program_options -lboost_filesystem -lboost_timer" \
  --enable-silent-rules --disable-dependency-tracking --disable-option-checking
make -j"${CPU_COUNT}"
make install

# This directory isn't needed and confuses conda
rm -rf $PREFIX/mkspecs

cd ${PREFIX}/lib
# Something is creating a symlink from ${PREFIX}/lib/\n
find . -type l -not -name "??*" -ls -delete
