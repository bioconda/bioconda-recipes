#!/bin/bash

# We run it from run_test.pl as if written in meta.yaml, the hack from
# https://github.com/conda-forge/perl-feedstock/pull/33 doesn't work
# (ie $ENV{'_'} returns nothing)

export PERL_INLINE_DIRECTORY=/tmp/ &&  \
perl -e 'use Inline C=>q{void greet(){printf("Hello, world\n");}};greet'
