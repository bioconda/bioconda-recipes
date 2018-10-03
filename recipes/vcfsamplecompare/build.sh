#!/bin/bash

set -e

perl Makefile.PL
make
#make test
perl t/run_tests.t
make install
