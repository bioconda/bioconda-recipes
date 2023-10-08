#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL
set -x -e

RM_DIR=${PREFIX}/share/perl-child
mkdir -p ${RM_DIR}
cp -r ${SRC_DIR}/* ${RM_DIR}

    cpan -i ExtUtils::MakeMaker
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
