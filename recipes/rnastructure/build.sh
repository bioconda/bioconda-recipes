#!/bin/sh
set -xe

# Fix for OSX build
if [ `uname` == Darwin ]; then
    CPP_FLAGS="${CXXFLAGS} -g -O3 -fopenmp -I${PREFIX}/include"
    sed -i.bak "s/gomp/omp/g" compiler.h
else
    CPP_FLAGS="${CXXFLAGS} -fopenmp -g -O3"
fi

# Build
make -j"${CPU_COUNT}" CC="${CC}" CXX="${CXX}" CPP_FLAGS="${CPP_FLAGS}" all

# Install binaries
mkdir -p $PREFIX/bin
install -v -m 0755 ./exe/* $PREFIX/bin/

# Install data tables
DATA_DEST=$PREFIX/share/${PKG_NAME}/data_tables
mkdir -p $DATA_DEST
cp -r ./data_tables/* $DATA_DEST/

# Script pour définir DATAPATH automatiquement à l'activation de l'env
mkdir -p $PREFIX/etc/conda/activate.d
echo "export DATAPATH=$DATA_DEST/" > $PREFIX/etc/conda/activate.d/rnastructure_path.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
echo "unset DATAPATH" > $PREFIX/etc/conda/deactivate.d/rnastructure_path.sh