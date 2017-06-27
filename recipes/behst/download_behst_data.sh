#!/bin/bash
set -euo pipefail

# BESHT's `project.sh` has hard-coded paths for data that are relative to the
# binary itself. Assume that project.sh has been installed into
# $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM and then symlinked to
# $PREFIX/bin, in which case we have to work out where the target is actually
# living so we can download data to the proper place in /share
#
BEHSTDIR=$(dirname $(dirname $(readlink $(which project.sh))))

echo "Downloading BEHST data to directory where BESHT executable is installed: $BEHSTDIR"

mkdir -p $BEHSTDIR/{temp,results,data}

curl -O -L "https://bitbucket.org/hoffmanlab/behst/get/0.1.tar.bz2" > "0.1.tar.bz2"
tar -xf "0.1.tar.bz2"

# bitbucket encodes the commit hash into the subdir which we don't know ahead
# of time based on version/tag
cp -r hoffmanlab-behst*/data/* $BEHSTDIR/data/
