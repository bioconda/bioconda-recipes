#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`

bash build.sh -l $LIBRARY_PATH

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

cp -r hapog_build/hapog ${PREFIX}/bin/hapog_bin

chmod a+x ${PREFIX}/bin/hapog_bin
