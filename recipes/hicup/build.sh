#!/bin/bash
set -eu -o pipefail

# HiCUP is a set of Perl scripts that also depend on R scripts and a local
# hicup_module.pm module. Here, we copy the tarball's contents (which also
# includes docs and config files) to $PREFIX/share. Then just the Perl scripts
# are symlinked to $PREFIX/bin. There are some additional fixes to the Perl
# scripts to make them run in the conda environment.

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
cp -R * $outdir

cd $outdir

for p in hicup_module.pm $(grep -l -R "usr/bin/perl" . ); do

  # Fix shebang lines
  sed -i.bak "s/\/usr\/bin\/perl/\/usr\/bin\/env perl/" $p

  # Convert $Bin to $RealBin so that links to the bin dir will be resolved.
  # This way we can symlink just the perl scripts in $PREFIX/bin and they can
  # find all the extra stuff (R scripts, etc) they need over in $PREFIX/share
  #
  # See http://perldoc.perl.org/FindBin.html
  sed -i.bak "s/\$Bin/\$RealBin/g" $p

  ln -s $outdir/$p $PREFIX/bin
done
