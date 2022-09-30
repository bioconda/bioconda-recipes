#!/bin/bash

set -e -o pipefail -x

CAIRO_OPT=
LIBS=
if [[ "$(uname)" == Darwin ]]; then
    CAIRO_OPT='cairo=no'
    LIBS="LIBS=-lc"
fi

make ${CAIRO_OPT} ${LIBS} errorcheck=no
export prefix=$PREFIX
make ${CAIRO_OPT} install 

cd gtpython
$PYTHON setup.py install 
