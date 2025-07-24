#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	sed -i.bak 's|-mtune=native -march=native|-march=armv8-a|' EDeN/Makefile
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	sed -i.bak 's|-mtune=native -march=native|-march=armv8.4-a|' EDeN/Makefile
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	sed -i.bak 's|-mtune=native -march=native|-march=x86-64-v3|' EDeN/Makefile
	;;
esac
rm -rf EDeN/*.bak

# set install paths
BIN="${PREFIX}/bin"
LIBEXEC="${PREFIX}/libexec/graphprot"
SHARE="${PREFIX}/share/graphprot"
mkdir -p "${BIN}" "${LIBEXEC}" "${SHARE}"

# compile EDeN
cd EDeN
make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"
cd ..

# run build tests
pytest

# install
install -v -m 0755 GraphProt.pl "${BIN}"
install -v -m 0755 bin/*.pl "${LIBEXEC}"
install -v -m 0755 bin/*.R "${LIBEXEC}"
install -v -m 0755 bin/*.sh "${LIBEXEC}"
install -v -m 0755 "bin/*.awk" "${LIBEXEC}"
install -v -m 0755 bin/RNAplfold_context_stdout bin/fastapl "${LIBEXEC}"
install -v -m 0755 EDeN/EDeN "${LIBEXEC}"
cp -rf bin/StructureLibrary "${LIBEXEC}"
cp -rf data "${SHARE}"
