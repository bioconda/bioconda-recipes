#!/bin/bash

set -e

perl Makefile.PL
make
#make test
perl t/run_tests.t --debug -1 --verbose 5
make install
