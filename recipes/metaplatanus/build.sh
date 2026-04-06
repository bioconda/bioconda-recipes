#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin/sub_bin"

make CXX="${CXX}"

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

make

ln -s $PREFIX/bin/samtools bin/samtools
ln -s $PREFIX/bin/bwa bin/bwa
ln -s $PREFIX/bin/minimap2 bin/minimaps
cp -rf nextPolish lib bin "$PREFIX/bin/sub_bin"
cd ../..
