#!/bin/bash
set -e -x -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

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

binaries="\
extract_fullseq \
"

mkdir -p "$PREFIX/bin"
#for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Platform: Mac"

    for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    make -j"${CPU_COUNT}" -C general CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    make -j"${CPU_COUNT}" -C bmtagger CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"

    for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
fi

chmod +x $PREFIX/bin/*
