#!/bin/bash

export LC_ALL="en_US.UTF-8"
export KMER="$PREFIX"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++03"

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

cd src

sed -i.bak 's/$(LOCAL_OS)/$(PREFIX)/' c_make.gen
case $(uname -m) in
    aarch64|arm64)
	sed -i.bak 's|-m64||g' c_make.as;;
esac
rm -f *.bak

CXXFLAGS="${CXXFLAGS}" make

cd ../

sed -i.bak "s/FileHandle;$/&\\nuse File::Basename;/" ${PREFIX}/bin/runCA
sed -i.bak 's/getBinDirectory()/dirname(__FILE__)/' ${PREFIX}/bin/runCA
sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g' ${PREFIX}/bin/runCA
rm -f ${PREFIX}/bin/*.bak
