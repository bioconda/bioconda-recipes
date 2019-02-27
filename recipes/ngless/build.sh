#!/bin/bash

export LIBRARY_PATH="${CONDA_PREFIX}/lib:/usr/lib:/usr/lib64"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib:/usr/lib:/usr/lib64"

export LDFLAGS="-L${CONDA_PREFIX}/lib"
export CPPFLAGS="-I${CONDA_PREFIX}/include"
export CFLAGS="-I${CONDA_PREFIX}/include"
export CPATH=${CONDA_PREFIX}/include


# stack relies on $HOME, so fake it:
mkdir -p fake-home
export HOME=$PWD/fake-home
export STACK_ROOT="$HOME/.stack"
stack setup --ghc-variant integersimple --local-bin-path ${CONDA_PREFIX}/bin
make install WGET="wget --no-check-certificate" prefix=$CONDA_PREFIX

#cleanup
rm -r .stack-work
