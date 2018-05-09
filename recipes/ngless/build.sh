#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include


# stack relies on $HOME, so fake it:
mkdir -p fake-home
export HOME=$PWD/fake-home
export STACK_ROOT="$HOME/.stack"
stack setup --local-bin-path ${PREFIX}/bin
make install WGET="wget --no-check-certificate" prefix=$PREFIX

#cleanup
rm -r .stack-work
