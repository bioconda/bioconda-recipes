#!/usr/bin/env bash

set -euxo pipefail

## perl version
perl_version=$(perl -e 'print $^V');
perl_version=${perl_version:1}

PERLLIB="${PREFIX}/lib/perl5/${perl_version}/perl_lib"
mkdir -p $PERLLIB

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/code"
mkdir -p "$PREFIX/data"
mkdir -p "$PREFIX/flatfiles"

cp -r ./code/scripts/* "$PREFIX/bin"
cp -r ./code/* "$PREFIX/code"
cp -r ./data/* "$PREFIX/data"
cp -r ./flatfiles/* "$PREFIX/flatfiles"

cpanm -l $PERLLIB --force DBIx::Class
cpanm -l $PERLLIB --force Data::Printer

# Make scripts executable
chmod -R a+x $PREFIX/bin/*.pl

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PERL5LIB=$PREFIX/code/modules:$PERLLIB/lib/perl5" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh
