if [ `uname` == Darwin ]; then
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/util.c
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" sources/oc1.h
        sed -i.bak "s~#include <malloc.h>~#include <malloc/malloc.h>~g" train/utils.c
fi

# fix typo in makefile in train
sed -i.bak "s~^escoreSTOP2:~scoreSTOP2:~g" train/makefile
sed -i.bak "s~^rfapp:~erfapp:~g" train/makefile

# fix shebang lines in perl scripts
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' train/trainGlimmerHMM
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/glimmhmm.pl

# make directories for storing training data and binaries
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
cp train/build-icm $PREFIX/bin/.
cp train/build-icm-noframe $PREFIX/bin/.
cp train/build1 $PREFIX/bin/.
cp train/build2 $PREFIX/bin/.
cp train/erfapp $PREFIX/bin/.
cp train/falsecomp $PREFIX/bin/.
cp train/findsites $PREFIX/bin/.
cp train/karlin $PREFIX/bin/.
cp train/score $PREFIX/bin/.
cp train/score2 $PREFIX/bin/.
cp train/scoreATG $PREFIX/bin/.
cp train/scoreATG2 $PREFIX/bin/.
cp train/scoreSTOP $PREFIX/bin/.
cp train/scoreSTOP2 $PREFIX/bin/.
cp train/splicescore $PREFIX/bin/.

# copy the training data
cp -R trained_dir $PREFIX/share/GlimmerHMM/