#!/usr/bin/env bash
set -xe

export DISABLE_AUTOBREW=1
export LC_ALL="en_US.UTF-8"

mkdir -p "$PREFIX/bin"

cp -rf STITCH.R $PREFIX/bin

cd $SRC_DIR/STITCH

if [[ "$(uname -m)" == "arm64" ]]; then
    # hard gfortran paths in R build(?) break the build on osx-arm64
    sed -i.bak 's|$(FLIBS)|-L$(PREFIX)/lib/gcc/arm64-apple-darwin20.0.0/13.3.0 -lgfortran -lquadmath -lm -L$(PREFIX)/lib/R/lib -lR -Wl,-framework -Wl,CoreFoundation|' src/Makevars
    rm -f src/*.bak
fi

${R} CMD INSTALL --build --install-tests . "${R_ARGS}"
