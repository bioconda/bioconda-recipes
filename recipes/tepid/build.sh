#!/bin/sh
set -x -e

#export INCLUDE_PATH="${PREFIX}/include"
#export LIBRARY_PATH="${PREFIX}/lib"
#export LD_LIBRARY_PATH="${PREFIX}/lib"
#export LDFLAGS="-L${PREFIX}/lib"
#export CPPFLAGS="-I${PREFIX}/include"
#pip install -r requirements.txt
ls ${PREFIX}
$PYTHON setup.py install


ls ${PREFIX}
#mkdir -p $PREFIX
