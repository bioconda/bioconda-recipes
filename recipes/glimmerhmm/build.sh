if [ `uname` == Darwin ]; then
    sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/util.c
    sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/oc1.h
    sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" train/utils.c
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

# make directories for storing training data and binaries
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/glimmerhmm
mkdir -p $PREFIX/share/glimmerhmm/train

# make
make -C sources CC=$CXX
make -C train clean && make -C train all C=$CC CC=$CXX

# copy the executables	
cp bin/glimmhmm.pl $PREFIX/bin/
cp sources/glimmerhmm $PREFIX/bin/
cp train/trainGlimmerHMM $PREFIX/bin/
cp train/build-icm $PREFIX/share/glimmerhmm/train/
cp train/build-icm-noframe $PREFIX/share/glimmerhmm/train/
cp train/build1 $PREFIX/share/glimmerhmm/train/
cp train/build2 $PREFIX/share/glimmerhmm/train/
cp train/erfapp $PREFIX/share/glimmerhmm/train/
cp train/falsecomp $PREFIX/share/glimmerhmm/train/
cp train/findsites $PREFIX/share/glimmerhmm/train/
cp train/karlin $PREFIX/share/glimmerhmm/train/
cp train/score $PREFIX/share/glimmerhmm/train/
cp train/score2 $PREFIX/share/glimmerhmm/train/
cp train/scoreATG $PREFIX/share/glimmerhmm/train/
cp train/scoreATG2 $PREFIX/share/glimmerhmm/train/
cp train/scoreSTOP $PREFIX/share/glimmerhmm/train/
cp train/scoreSTOP2 $PREFIX/share/glimmerhmm/train/
cp train/splicescore $PREFIX/share/glimmerhmm/train/

# copy the perl modules
cp train/*.pm $PREFIX/share/glimmerhmm/train/

# copy the training data
cp -R trained_dir $PREFIX/share/glimmerhmm/