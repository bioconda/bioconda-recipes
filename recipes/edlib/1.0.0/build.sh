#!/bin/bash

cmake -D CMAKE_BUILD_TYPE=Release .
make VERBOSE=1
make install DESTDIR=$PREFIX

cp bin/aligner $PREFIX/bin/

