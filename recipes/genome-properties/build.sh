#!/usr/bin/env bash

set -euxo pipefail

cpanm DBIx::Class
cpanm Data::Printer

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/data"
mkdir -p "$PREFIX/flatfiles"

cp -r ./code/scripts/* "$PREFIX/bin"
cp -r ./data/* "$PREFIX/data"
cp -r ./flatfiles/* "$PREFIX/flatfiles"

# Make scripts executable
chmod -R a+x $PREFIX/bin/*.pl

export PERL5LIB="$PREFIX/code/modules"