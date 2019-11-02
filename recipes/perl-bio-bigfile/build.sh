#!/bin/bash
export LD=$CC

# Compiling the kent source tree
export CPPFLAGS=-I$PREFIX/include
make -C kent/src/lib
export KENT_SRC=$SRC_DIR/kent/src
export PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0
perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site
