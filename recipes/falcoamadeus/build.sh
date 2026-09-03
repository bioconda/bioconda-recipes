#!/bin/bash
set -xe

# Append the prefix search paths without introducing an empty (":") element,
# which would otherwise be interpreted as the current directory.
export CPLUS_INCLUDE_PATH="${PREFIX}/include${CPLUS_INCLUDE_PATH:+:${CPLUS_INCLUDE_PATH}}"
export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
# Keep -O3; rely on the toolchain's baseline -march/-mtune so the package stays
# compatible with every CPU on the target conda platform (no -march=x86-64-v3).
export CXXFLAGS="${CXXFLAGS:-} -O3"

# The adapter/contaminant/limits lists in Configuration/ are looked up at
# runtime relative to the compile-time PROGRAM_PATH, which configure.ac hardcodes
# to $srcdir. Point it at a stable location inside the prefix and install the
# data there so the installed binary finds it from any working directory.
DATADIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
sed -i.bak "s|\[\"\$srcdir\"\]|[\"${DATADIR}\"]|" configure.ac

# up-to-date config.guess/config.sub for newer platforms
cp -f "${BUILD_PREFIX}/share/gnuconfig/config."* . 2>/dev/null || true

autoreconf -if
./configure --prefix="${PREFIX}" --enable-hts \
  --disable-dependency-tracking --enable-silent-rules \
  CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install

mkdir -p "${DATADIR}/Configuration"
cp Configuration/* "${DATADIR}/Configuration/"
