#!/usr/bin/env bash

set -euxo pipefail

cpanm -l "$PREFIX/code/modules" --force --installdeps DBIx::Class
cpanm -l "$PREFIX/code/modules" --force --installdeps Data::Printer

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/code"
mkdir -p "$PREFIX/data"
mkdir -p "$PREFIX/flatfiles"

cp -r ./code/scripts/* "$PREFIX/bin"
cp -r ./code/* "$PREFIX/code"
cp -r ./data/* "$PREFIX/data"
cp -r ./flatfiles/* "$PREFIX/flatfiles"

# Make scripts executable
chmod -R a+x $PREFIX/bin/*.pl

export PERL5LIB="$PREFIX/code/modules"