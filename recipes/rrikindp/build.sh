#!/bin/sh

if [[ ${target_platform} == osx-64 ]]; then
  export CONDA_BUILD_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
fi

$PYTHON -m pip install . --no-deps --ignore-installed -vv

cd src/rrikindp

make -j ${CPU_COUNT} CXXFLAGS+="-I${CONDA_PREFIX}/include"
install RRIkinDP "${PREFIX}/bin"
