#!/bin/bash

set -e -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin


if [ "$(uname)" == "Darwin" ]; then
		cp -r bin $outdir
		cp -r share $outdir
else
		pushd .
		PREFIX=$outdir ./spades_compile.sh
		popd
fi

ln -s $outdir/bin/* $PREFIX/bin
