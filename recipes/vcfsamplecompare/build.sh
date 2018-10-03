#!/bin/bash

set -e

perl Makefile.PL
make
#make test
echo "RUNNING TESTS"
#perl -e 'use CommandLineInterface;print "Should get an INC error\n\n"'
#The above does generate an error.
perl -Ilib -e 'print STDOUT "This is STDOUT\n";print STDERR "This is STDERR\n";use CommandLineInterface;' -- --usage --debug -1
#perl t/run_tests.t --usage
make install
