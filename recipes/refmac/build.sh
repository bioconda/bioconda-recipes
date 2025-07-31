#!/bin/bash
set -exo pipefail

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export FC="${BUILD_PREFIX}/bin/gfortran"
export F77="${BUILD_PREFIX}/bin/gfortran"

pushd fftw2
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
aclocal
libtoolize --force
automake --add-missing --force-missing
autoconf
./configure \
  --prefix="${PREFIX}" \
  --enable-shared \
  --enable-float \
  --disable-static \
  --disable-debug \
  --disable-dependency-tracking \
  --enable-silent-rules \
  --disable-option-checking
make -j"${CPU_COUNT}"
make install
popd

pushd refmac
cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_Fortran_COMPILER="${FC}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DMMDB2_LIBRARY="${PREFIX}/lib/libmmdb2${SHLIB_EXT}"
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
popd

# `refmac5` requires these CCP4 config files to be run successfully
touch "${PREFIX}/share/ccp4/"{default.def,environ.def}
