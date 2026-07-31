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

case $(uname -s) in
    Linux)
	sed -i.bak "s|, 'omp'||" setup.py ;;
esac

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -f *.bak

cd src/rrikindp

make CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 RRIkinDP "${PREFIX}/bin"

cd ../../

CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" ${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
