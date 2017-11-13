#!/bin/bash

sed -i "s^PREFIX = /usr/local^PREFIX = $CONDA_PREFIX^" src/GNUmakefile
CLFAGS=$CONDA_PREFIX/lib
LDFLAGS=$CONDA_PREFIX/lib
(cd src ; make && make install )
