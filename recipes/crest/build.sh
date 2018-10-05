#!/bin/bash

export PERL5LIB="$PREFIX/lib/perl5/site_perl/5.22.0"

cp *.pl $PERL5LIB
cp *.pl $PREFIX/bin
cp *.pm $PERL5LIB
cp ptrfinder $PREFIX/bin

