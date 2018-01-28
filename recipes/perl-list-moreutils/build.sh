#!/bin/bash

# Make sure this goes in site
set -x -e

echo $PATH
which gcc
which cc

cpanm --installdeps .


perl Makefile.PL INSTALLDIRS=site
make
make test
make install
