#!/bin/bash
./configure --prefix=$PREFIX
make AM_MAKEFLAGS=-e
install -d "${PREFIX}/bin"
install src/variant "${PREFIX}/bin/"
