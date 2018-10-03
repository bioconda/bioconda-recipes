#!/bin/bash

set -e

perl Makefile.PL
make
#make test
echo "RUNNING TESTS"
perl t/run_tests.t --usage
make install
