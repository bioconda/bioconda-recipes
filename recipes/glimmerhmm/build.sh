#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	sed -i.bak "s~#include <malloc.h>~#include <stdlib.h>~g" sources/util.c
	sed -i.bak "s~#include <malloc.h>~#include <stdlib.h>~g" sources/oc1.h
	sed -i.bak "s~#include <malloc.h>~#include <stdlib.h>~g" train/utils.c
	rm -rf sources/*.bak
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -headerpad_max_install_names"
fi

# fix typos in train makefile
sed -i.bak "s|^escoreSTOP2:|scoreSTOP2:|g" train/makefile
sed -i.bak "s|^rfapp:|erfapp:|g" train/makefile
sed -i.bak "s| trainGlimmerHMM||g" train/makefile
sed -i.bak "s|all:    build-icm|all:    misc.o build-icm.o build-icm-noframe.o build-icm|g" train/makefile

# fix perl scripts
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' train/trainGlimmerHMM
sed -i.bak 's|FindBin;|FindBin qw($RealBin);|g' train/trainGlimmerHMM
sed -i.bak 's|$FindBin::Bin;|"$RealBin/../share/glimmerhmm/train";|g' train/trainGlimmerHMM
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/glimmhmm.pl

rm -rf train/*.bak
rm -rf bin/*.bak

# make directories for storing training data and binaries
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/glimmerhmm
mkdir -p $PREFIX/share/glimmerhmm/train

# make
make -C sources CC="$CXX" -j"${CPU_COUNT}"
make -C train clean && make -C train all C="$CC" CC="$CXX" -j"${CPU_COUNT}"

# copy the executables	
install -v -m 0755 bin/glimmhmm.pl $PREFIX/bin
install -v -m 0755 sources/glimmerhmm $PREFIX/bin
install -v -m 0755 train/trainGlimmerHMM $PREFIX/bin
install -v -m 0755 train/build-icm train/build-icm-noframe train/build1 train/build2 train/erfapp $PREFIX/share/glimmerhmm/train
install -v -m 0755 train/falsecomp train/findsites train/karlin train/score train/score2 train/scoreATG $PREFIX/share/glimmerhmm/train
install -v -m 0755 train/scoreATG2 train/scoreSTOP train/scoreSTOP2 train/splicescore $PREFIX/share/glimmerhmm/train

# copy the perl modules
cp -f train/*.pm $PREFIX/share/glimmerhmm/train/

# copy the training data
cp -Rf trained_dir $PREFIX/share/glimmerhmm/
