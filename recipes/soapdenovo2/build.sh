#!/bin/bash
set -x -e

mkdir -p "$PREFIX/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 ${LDFLAGS} ${CPPFLAGS}"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

case $(uname -s) in
    Darwin)
	cp -f ${RECIPE_DIR}/spinLock.h sparsePregraph/inc/
	;;
esac

cp -f ${PREFIX}/lib/libbam.a standardPregraph/inc/
cp -f ${PREFIX}/lib/libbam.a sparsePregraph/inc/

# sparsePregraph and the final link are C++; standardPregraph is C
sed -i.bak "s|^CC[[:space:]]*=[[:space:]]*g++|CC = ${CXX}|" Makefile sparsePregraph/Makefile
sed -i.bak "s|^CC[[:space:]]*=[[:space:]]*gcc|CC = ${CC} -std=gnu17 -fcommon -fpermissive|" standardPregraph/Makefile

rm -f *.bak
rm -f sparsePregraph/*.bak
rm -f standardPregraph/*.bak

make clean

if [[ "$(uname -s)" == "Darwin" ]]; then
	make SOAPdenovo-63mer LIBS="-pthread -lbam -lz -lm"
	make SOAPdenovo-127mer LIBS="-pthread -lbam -lz -lm"
else
	make SOAPdenovo-63mer
	make SOAPdenovo-127mer
fi

cd fusion

if [[ "$(uname -s)" == "Darwin" ]]; then
	make LIBS="-pthread -lm"
else
	make
fi

install -v -m 0755 ../SOAPdenovo-63mer "$PREFIX/bin"
install -v -m 0755 ../SOAPdenovo-127mer "$PREFIX/bin"
install -v -m 0755 SOAPdenovo-fusion "$PREFIX/bin"
