#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo "Done!"

echo "Fetching and install bcftools"

bcftools='bcftools-1.5'

curl -s -L https://github.com/samtools/bcftools/releases/download/1.5/bcftools-1.5.tar.bz2 > bcftools.tar.bz2
tar -jxf bcftools.tar.bz2

#clean up
rm bcftools.tar.bz2

cp bcfplugins/filter_snv_density.c $bcftools/plugins
cd $bcftools

./configure
make

#copy the compiled 
cp plugins/filter_snv_density.so $DIR/bcfplugins/

cd $DIR

#temporary env variable for make test
export PATH=$bcftools:$PATH
export BCFTOOLS_PLUGINS=bcfplugins


#temporary cpan modules
cpanm -i Switch -L . || :
cpanm -i Test::JSON -L . || :
cpanm -i String::Util -L . || :
cpanm -i JSON::Any -L . || :
export LANG=C
export PERL5LIB=$DIR/lib/perl5


# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
    fi


#remove bcftools
rm -rf $bcftools/
