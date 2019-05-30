if [ `uname` == Darwin ]; then
	export MACOSX_DEPLOYMENT_TARGET=10.9
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/util.c
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/oc1.h
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" train/utils.c
fi


sed -i.bak "s/CC=g++/CC=GXX/g" sources/makefile

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/GlimmerHMM/trained_dir

# cd into the sources
cd sources && make
cd ../train && make
cd ..

#copy the executables	
cp bin/glimmhmm.pl $PREFIX/bin/.
cp sources/glimmerhmm $PREFIX/bin/.
cp train/trainGlimmerHMM $PREFIX/bin/.

# copy the training data
cp -R trained_dir $PREFIX/GlimmerHMM/