#!/bin/bash
export LD=$CC

# Compiling the kent source tree
wget http://hgdownload.cse.ucsc.edu/admin/jksrc.zip
unzip jksrc.zip
(cd kent/src/lib && make)
export KENT_SRC=$PWD/kent/src

perl Build.PL --extra_compiler_flags "-I$PREFIX/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site

