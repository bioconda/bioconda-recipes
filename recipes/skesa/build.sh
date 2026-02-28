#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's/-Wl,-Bstatic//' Makefile.nongs
	sed -i.bak 's/-Wl,-Bdynamic -lrt//' Makefile.nongs
fi
sed -i.bak 's/-lpthread/-pthread/' Makefile.nongs
rm -rf *.bak

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

make -f Makefile.nongs \
	BOOST_PATH="${PREFIX}" \
	CC="${CXX} -std=c++14 ${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS}"

install -v -m 0755 skesa saute saute_prot gfa_connector kmercounter "${PREFIX}/bin"
