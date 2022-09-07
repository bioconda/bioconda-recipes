#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
echo $PREFIX

python setup.py install --record record.txt
bash build.sh -l $LIBRARY_PATH
cp -r hapog_build/hapog ${PREFIX}/bin/hapog_bin
