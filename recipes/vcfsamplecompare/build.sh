#!/bin/bash

set -e

perl Makefile.PL
make
#make test
echo "RUNNING TESTS"
perl t/run_tests.t --debug -100 --verbose 5
make install
