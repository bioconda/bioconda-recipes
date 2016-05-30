#!/bin/bash

FORCE_UNSAFE_CONFIGURE=1 ./configure CPPFLAGS="-fgnu89-inline" --prefix=$PREFIX

make
make install
