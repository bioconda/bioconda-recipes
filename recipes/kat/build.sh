#!/bin/bash
set -x -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-but-set-variable -Wno-vla-cxx-extension -Wno-sizeof-pointer-div"
export LC_ALL="en_US.UTF-8"
export PYTHONPATH="${SP_DIR}"
export PYTHON_NOVERSION_CHECK="${PY_VER}"

mkdir -p ${PREFIX}/bin

# https://stackoverflow.com/questions/22401500/autoconf-error-possibly-undefined-macro-ac-libobj
cd deps/jellyfish-2.2.0 && aclocal && cd ../../

#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac
sed -i.bak 's|'3.5'|'3.10'|' configure.ac
rm -rf *.bak

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Linux" ]]; then
  export CXXFLAGS="${CXXFLAGS} -Wno-catch-value"
fi

autoreconf -if
./configure --prefix="${PREFIX}" CC="${CC}" CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" CPPFLAGS="${CPPFLAGS}" \
  PYTHON="${PYTHON}" PYTHON_VERSION="${PY_VER}" LIBS="-lz -lboost_program_options -lboost_filesystem -lboost_timer" \
  --enable-silent-rules --disable-dependency-tracking --disable-option-checking

make -j"${CPU_COUNT}"
make install

# This directory isn't needed and confuses conda
rm -rf $PREFIX/mkspecs
