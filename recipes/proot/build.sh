#!/bin/bash

sed -i "s^PREFIX = /usr/local^PREFIX = $PREFIX^" src/GNUmakefile
CLFAGS=$PREFIX/lib
LDFLAGS=$PREFIX/lib
(cd src ; make && make install )
