#!/bin/bash
export LD=$CC

# Compiling the kent source tree
(cd kent/kent/src/lib && make)
export KENT_SRC=$SRC_DIR/kent/kent/src

perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site

