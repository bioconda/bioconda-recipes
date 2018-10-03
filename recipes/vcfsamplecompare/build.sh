#!/bin/bash

set -e

perl Makefile.PL
make
#make test
echo "RUNNING TESTS"
perl -e 'use CommandLineInterface;print "Should get an INC error\n\n"'
perl -Ilib -e 'use CommandLineInterface;' -- --usage
perl t/run_tests.t --usage
make install
