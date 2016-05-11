#!/bin/sh
perl Makefile.PL
make -j ${CPU_COUNT}
make test
make install
