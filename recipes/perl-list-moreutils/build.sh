#!/bin/bash

# Make sure this goes in site
set -x -e
export PATH=/opt/rh/devtoolset-2/root/usr/bin/:$PATH

HOME=/tmp cpanm --installdeps .


perl Makefile.PL INSTALLDIRS=site
make
make test
make install
