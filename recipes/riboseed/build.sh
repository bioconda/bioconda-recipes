#!/bin/bash
set -e -o pipefail

$PYTHON setup.py build_ext --inplace --force
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
# Add more build steps here, if they are necessary.
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM-SPAdes3.9.1
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    THISOS="linux"
    curl -LO https://github.com/nickp60/riboSeed/raw/subspades/SPAdes-3.9.1-linux.tar.gz
        # ...
elif [[ "$OSTYPE" == "darwin"* ]]; then
    THISOS="osx"
    curl -LO https://github.com/nickp60/riboSeed/raw/subspades/SPAdes-3.9.1-osx.tar.gz
else
    echo "No SPAdes3.9.1 binaries available for $OSTYPE"
    exit 1
fi

tar xzf SPAdes-3.9.1-$THISOS.tar.gz
# stolen from the SPAdes build.sh
mkdir -p $outdir
mkdir -p $PREFIX/bin

cp -r $THISOS/bin $outdir
cp -r $THISOS/share $outdir

ln -s $outdir/bin/* $PREFIX/bin
