#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

DATA_DEST="$PREFIX/share/${PKG_NAME}/data_tables"
mkdir -p "$DATA_DEST"

# Fix for OSX build
if [[ `uname -s` == Darwin ]]; then
	CPP_FLAGS="${CXXFLAGS} -g -O3 -fopenmp -I${PREFIX}/include"
	sed -i.bak "s/gomp/omp/g" compiler.h
else
	CPP_FLAGS="${CXXFLAGS} -fopenmp -g -O3"
fi

case $(uname -m) in
    aarch64)
	export CPP_FLAGS="${CPP_FLAGS} -march=armv8-a"
	;;
    arm64)
	export CPP_FLAGS="${CPP_FLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CPP_FLAGS="${CPP_FLAGS} -march=x86-64-v3"
	;;
esac

# Build
make -j"${CPU_COUNT}" CC="${CC}" CXX="${CXX}" CPP_FLAGS="${CPP_FLAGS}" all

# Install binaries
install -v -m 0755 ./exe/* "$PREFIX/bin"

# Install data tables
cp -r ./data_tables/* $DATA_DEST/

# Script pour définir DATAPATH automatiquement à l'activation de l'env
mkdir -p $PREFIX/etc/conda/activate.d
echo "export DATAPATH=$DATA_DEST/" > $PREFIX/etc/conda/activate.d/rnastructure_path.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
echo "unset DATAPATH" > $PREFIX/etc/conda/deactivate.d/rnastructure_path.sh
