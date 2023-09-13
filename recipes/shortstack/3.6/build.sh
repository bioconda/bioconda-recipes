#!/bin/bash
set -eu -o pipefail

# create destination folder
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR

# install files
chmod +x $SRC_DIR/ShortStack
# https://bioconda.github.io/troubleshooting.html#usr-bin-perl-or-usr-bin-python-not-found
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $SRC_DIR/ShortStack
cp $SRC_DIR/ShortStack $OUTDIR
cp $SRC_DIR/README $OUTDIR

# create executables
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

ShortStack=$BINDIR/ShortStack
echo "#!/bin/bash" > $ShortStack;
echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $ShortStack;
echo '$DIR/../share/'$(basename $OUTDIR)/ShortStack '$@' >> $ShortStack;
chmod +x $ShortStack

