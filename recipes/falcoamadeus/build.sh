#!/bin/bash
set -xe

export CPLUS_INCLUDE_PATH="${PREFIX}/include:${CPLUS_INCLUDE_PATH:-}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH:-}"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS:-} -O3"

case $(uname -m) in
  aarch64) export CXXFLAGS="${CXXFLAGS} -march=armv8-a" ;;
  arm64)   export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a" ;;
  x86_64)  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3" ;;
esac
if [[ $(uname -s) == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# The adapter/contaminant/limits lists in Configuration/ are looked up at
# runtime relative to the compile-time PROGRAM_PATH, which configure.ac hardcodes
# to $srcdir. Point it at a stable location inside the prefix and install the
# data there so the installed binary finds it from any working directory.
DATADIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
sed -i.bak "s|\[\"\$srcdir\"\]|[\"${DATADIR}\"]|" configure.ac

# up-to-date config.guess/config.sub for newer platforms
cp -f "${BUILD_PREFIX}/share/gnuconfig/config."* . 2>/dev/null || true

autoreconf -if
./configure --enable-hts --disable-dependency-tracking --enable-silent-rules \
  CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install prefix="${PREFIX}"

mkdir -p "${DATADIR}/Configuration"
cp Configuration/* "${DATADIR}/Configuration/"
