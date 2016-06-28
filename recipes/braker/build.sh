#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

echo "Files are `ls -lah`"
cp $RECIPE_DIR/Build.PL ./
perl ./Build.PL
./Build manifest
./Build install --installdirs site

#export PERL_BASH="/usr/bin/perl"
#sed -i "s@$PERL_BASH@$PREFIX/bin/perl@" *pl
#
#export PERL_BASH="/usr/bin/env perl"
#sed -i "s@$PERL_BASH@$PREFIX/bin/perl@" *pl

#mv *pl $PREFIX/bin/
mv *pm $PREFIX/bin/
