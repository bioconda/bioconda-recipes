#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export HTSLIB_DIR="${PREFIX}"
export LD="${CC}"

export LC_ALL="en_US.UTF-8"

perl Build.PL --extra_compiler_flags "-O3 -I${PREFIX}/include"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site
