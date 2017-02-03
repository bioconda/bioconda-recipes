#!/usr/bin/env bash

#mkdir -p $PREFIX/opt/sspace
#mv ./* $PREFIX/opt/sspace
#cd $PREFIX/opt/sspace
#ln -s $PREFIX/opt/sspace/SSPACE_Standard_v3.0.pl $PREFIX/bin/SSPACE_Standard_v3.0.pl
#ln -s $PREFIX/opt/sspace/SSPACE_Standard_v3.0.pl $PREFIX/bin/SSPACE
#
#cd $PREFIX/opt/sspace/dotlib/
#wget -c http://cpansearch.perl.org/src/GBARR/perl5.005_03/lib/getopts.pl

cpanm --notest Perl4::CoreLibs

mkdir -p  perl-build/lib
find -name "*.pl" | xargs -I {} mv {} perl-build
find -name "*.pm" | xargs -I {} mv {} perl-build/lib

cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

#exit 1
