#!/bin/bash

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
chmod u+rw ${PREFIX}/bin/lwp-*
