#!/bin/bash
set -eu -o pipefail

# specify and create /bin/ directory
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

# make executable and fix the shebang from /usr/bin/perl to /usr/bin/env perl
chmod +x $SRC_DIR/ShortStack
# https://bioconda.github.io/troubleshooting.html#usr-bin-perl-or-usr-bin-python-not-found
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $SRC_DIR/ShortStack

# Install the script and its README
cp $SRC_DIR/ShortStack $BINDIR
cp $SRC_DIR/README $BINDIR
