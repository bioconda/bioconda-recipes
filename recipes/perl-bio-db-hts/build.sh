#!/bin/bash
#cpanm -i --configure-args "CFLAGS=-I$prefix/include" .

perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site
