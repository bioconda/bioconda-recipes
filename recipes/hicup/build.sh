#!/bin/bash
set -eu -o pipefail

# HiCUP is a set of Perl scripts that also depend on R scripts and a local
# hicup_module.pm module. Here, we copy the tarball's contents (which also
# includes docs and config files) to $PREFIX/share. Then just the Perl scripts
# are symlinked to $PREFIX/bin. There are some additional fixes to the Perl
# scripts to make them run in the conda environment.

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir

cd $outdir

for p in hicup_module.pm $(grep -l -R "usr/bin/perl" . ); do

  # Fix shebang lines
  sed -i.bak "s/\/usr\/bin\/perl/\/usr\/bin\/env perl/" $p

  ln -s $outdir/$p $PREFIX/bin
done
