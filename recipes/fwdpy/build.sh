#!/bin/bash

export CFLAGS="-I${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
#These are helpful/necessary on OS X.
#this package requires -fopenmp, which 
#clang does not support.  Further,
#the dependent libraries (libsequence)
#are built on Anaconda/OS X using GCC,
#so we should use GCC here to ensure ABI
#compatibility.
export CC=gcc
export CXX=g++
$PYTHON setup.py install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
