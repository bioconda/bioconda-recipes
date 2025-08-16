#!/bin/bash

mkdir -p "${PREFIX}/bin"

if [[ "${target_platform}" == "osx-64" ]]; then
  export CONDA_BUILD_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
fi

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' setup.py
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' setup.py
	;;
esac

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

cd src/rrikindp

make CXXFLAGS+="-O3 -I${CONDA_PREFIX}/include" -j"${CPU_COUNT}"
install -v -m 0755 RRIkinDP "${PREFIX}/bin"
