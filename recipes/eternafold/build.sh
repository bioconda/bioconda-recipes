#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p -v "$PREFIX/bin/eternafold-bin"
mkdir -p -v "$PREFIX/lib/eternafold-lib"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++11 -O3|-std=c++14 -O3 -march=armv8-a|' src/Makefile
	;;
    arm64)
	sed -i.bak 's|-std=c++11 -O3|-std=c++14 -O3 -march=armv8.4-a|' src/Makefile
	;;
    x86_64)
	sed -i.bak 's|-std=c++11 -O3|-std=c++14 -O3 -march=x86-64-v3|' src/Makefile
	;;
esac

case $(uname -m) in
    aarch64|arm64)
        sed -i.bak 's|-mfpmath=sse -msse -msse2 -msse3||' src/Makefile
	sed -i.bak 's|-xCORE-AVX-I||' src/Makefile
        ;;
esac

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' src/*.pl
rm -f src/*.bak

# Move to conda-specific src directory location
cd src

# Build Eternafold
case $(uname -s) in
	"Darwin")
	make CXX="${CXX}" -j"${CPU_COUNT}"
	;;
	*)
	make multi CXX="${CXX}" -j"${CPU_COUNT}"
	;;
esac

# Move built binaries to environment-specific location
install -v -m 0755 contrafold api_test score_prediction "$PREFIX/bin/eternafold-bin"
install -v -m 0755 *.pl "$PREFIX/bin/eternafold-bin"

# Move relevant repo files to lib folder
cp -Rf $SRC_DIR/* $PREFIX/lib/eternafold-lib/

# Symlink binary as eternafold and place in PATH-available location
ln -sf $PREFIX/bin/eternafold-bin/contrafold $PREFIX/bin/eternafold

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p -v "${PREFIX}/etc/conda/${CHANGE}.d"
    cp -f "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
