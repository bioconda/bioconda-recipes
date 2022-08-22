#!/usr/bin/env bash

sed -i.backup \
    -e "s|gcc|$CC|g"
    util/Makefile

make
make install
