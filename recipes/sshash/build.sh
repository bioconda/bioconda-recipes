#!/bin/bash -euo

unamestr=`uname`

if [ "$unamestr" == 'Darwin' ];
then
  if [[ $(uname -m) == 'x86_64' ]]; then
    echo "OSX x86-64: attempting to fix broken (old) SDK behavior"
    export CFLAGS="${CFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
  fi
  export MACOSX_DEPLOYMENT_TARGET=10.15
  export MACOSX_SDK_VERSION=10.15
  export CFLAGS="${CFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY -fno-define-target-os-macros"
  export CXXFLAGS="${CXXFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY"
else
  export CFLAGS="${CFLAGS} -fcommon"
  export CXXFLAGS="${CXXFLAGS} -fcommon"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCONDA_BUILD=TRUE \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
