#!/bin/bash
set -x -e

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' ContigsCompactor-v0.2.0/ContigsMerger/Makefile ;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' ContigsCompactor-v0.2.0/ContigsMerger/Makefile ;;
esac
rm -f Release/*.bak

case $(uname -s) in
    "Darwin")
	sed -i.bak 's| -static||' TERefiner/Makefile && rm -f TERefiner/*.bak ;;
esac

pushd TERefiner
make CC="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 TERefiner_1 "${PREFIX}/bin"
popd

pushd ./ContigsCompactor-v0.2.0/ContigsMerger
make CC="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 ContigsMerger "${PREFIX}/bin"
popd

install -v -m 0755 *.py "${PREFIX}/bin"
