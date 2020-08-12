#!/bin/bash

set -e

perl Makefile.PL INSTALLDIRS=site
make
make install
