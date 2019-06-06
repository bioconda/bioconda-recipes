if [ `uname` == Darwin ]; then
	export MACOSX_DEPLOYMENT_TARGET=10.9
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/util.c
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/oc1.h
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" train/utils.c
fi

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/GlimmerHMM/trained_dir

# cd into the sources
if [ `uname` == Darwin ]; then
        cd sources && make CC=$CXX
        cd ../train && make C=$C CC=$CXX
        cd ..
else
        cd sources && make CC=$GXX 
        cd ../train && make C=$C CC=$GXX
        cd ..
fi

#copy the executables	
cp bin/glimmhmm.pl $PREFIX/bin/.
cp sources/glimmerhmm $PREFIX/bin/.
cp train/trainGlimmerHMM $PREFIX/bin/.

# copy the training data
cp -R trained_dir $PREFIX/GlimmerHMM/