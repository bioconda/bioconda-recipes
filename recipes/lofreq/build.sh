#!/bin/bash
set -eu
env
gcc --version


if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -wn .
    patch $SRC_DIR/src/tools/setup.py $RECIPE_DIR/setup.py_patch
fi

# ST_VERSION=1.2
# HTS_VERSION=1.2.1
# wget -O samtools-1.2.tar.gz https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2
# tar -xjvpf samtools-1.2.tar.gz
# cd samtools-1.2
# make
# cd ..


ST_VERSION=1.2
HTS_VERSION=1.2.1
curl -L http://downloads.sourceforge.net/project/samtools/samtools/$ST_VERSION/samtools-$ST_VERSION.tar.bz2 | tar xvj -C ../

cd ../samtools-$ST_VERSION
C_INCLUDE_PATH=/opt/conda/envs/_build/include/:/opt/conda/envs/_build/include/ncurses/ make
cd -

SAMTOOLS=$SRC_DIR/../samtools-$ST_VERSION HTSLIB=$SRC_DIR/../samtools-$ST_VERSION/htslib-$HTS_VERSION ./configure --prefix $PREFIX
make
make install

#mkdir -p $PREFIX/bin
#cp bin/* $PREFIX/bin


#https://github.com/conda/conda-recipes/blob/master/libtiff/build.sh
