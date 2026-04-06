#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin/sub_bin"

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak 's|-finline-limit-50000||' src/metaplatanus_core/Makefile
	rm -f src/metaplatanus_core/*.bak
fi

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 metaplatanus \
	src/scripts/tgsgapcloser_mod "$PREFIX/bin"
install -v -m 0755 sub_bin/* "$PREFIX/bin/sub_bin"

cd src/nextpolish

if [[ `uname -s` == "Darwin" ]]; then
	ln -s `which ${CC}` `dirname \`which ${CC}\``/clang
	ln -s `which ${CXX}` `dirname \`which ${CXX}\``/clang++
else
	ln -s `which ${CC}` `dirname \`which ${CC}\``/gcc
	ln -s `which ${CXX}` `dirname \`which ${CXX}\``/g++
fi

make -j"${CPU_COUNT}"

ln -s $PREFIX/bin/samtools bin/samtools
ln -s $PREFIX/bin/bwa bin/bwa
ln -s $PREFIX/bin/minimap2 bin/minimaps
cp -rf nextPolish lib bin "$PREFIX/bin/sub_bin"
cd ../..
