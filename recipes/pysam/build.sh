#!/bin/bash

# Use internal htslib
chmod a+x ./htslib/configure

export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
export HTSLIB_CONFIGURE_OPTIONS="--disable-libcurl"

$PYTHON setup.py install
