#!/bin/bash

set -e -o pipefail -x

CAIRO_OPT=
if [[ "$(uname)" == Darwin ]]; then
		CAIRO_OPT='cairo=no'
fi

make ${CAIRO_OPT} errorcheck=no
export prefix=$PREFIX
make ${CAIRO_OPT} install 

cd gtpython
$PYTHON setup.py install 
