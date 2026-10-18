#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/data"

sed -i.bak 's|2.08|2.09|' transterm.cc
sed -i.bak 's|-O3|-O3 -std=c++03 -march=x86-64-v3|' Makefile

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac
rm -f *.bak

make

install -v -m 0755 transterm 2ndscore calibrate.sh make_expterm.py mfold_rna.sh random_fasta.py "$PREFIX/bin"

mv expterm.dat "$PREFIX/data"

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export TRANSTERMHP=$PREFIX/data/expterm.dat" > $PREFIX/etc/conda/activate.d/transtermhp.sh
mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset TRANSTERMHP" > $PREFIX/etc/conda/deactivate.d/transtermhp.sh
