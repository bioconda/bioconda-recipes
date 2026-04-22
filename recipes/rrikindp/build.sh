#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -fopenmp"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' setup.py
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' setup.py
	;;
esac

cd src/rrikindp

make CXXFLAGS="${CXXFLAGS} "LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 RRIkinDP "${PREFIX}/bin"

cd ../../

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
