#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"

# "fix" shebang line (space seems to confuse conda-build)
find util -name "*pl.in" -exec sed -i -e 's/^\#! @PERL@/\#!@PERL@/' {} \;

./configure --prefix=${PREFIX} --with-simd-level=sse42
make -j 2
make install prefix=${PREFIX}
