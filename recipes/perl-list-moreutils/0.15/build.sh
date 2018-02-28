#!/usr/bin/env bash

# Make sure this goes in site
set -x -e

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
