#!/bin/bash

#cd pygtftk-0.9.1
#make install
export C_INCLUDE_PATH=$PREFIX/include
$PYTHON setup.py install --single-version-externally-managed --record=record.txt  # Python command to install the script.
#mkdir -p $PREFIX/bin
#cp bin/* $PREFIX/bin

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
