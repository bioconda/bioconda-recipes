#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

MAXBIN_HOME="$PREFIX/opt/MaxBin-$PKG_VERSION"

mkdir -p "$PREFIX/bin"
mkdir -p "$MAXBIN_HOME"

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

# make
cp -f makefile.new src/
cd src

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' makefile.new && rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' makefile.new && rm -f *.bak
	;;
esac

make -f makefile.new CXX="${CXX}"

cp -Rf $SRC_DIR/* $MAXBIN_HOME/

cd $MAXBIN_HOME

# fix perl path
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' *.pl
# fix script's bin dir to follow symlinks
sed -i.bak 's|\$Bin|\$RealBin|' run_MaxBin.pl
rm -f *.bak

chmod a+x *.pl

ln -s $MAXBIN_HOME/run_MaxBin.pl $PREFIX/bin/run_MaxBin.pl
