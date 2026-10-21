#!/bin/bash

# LAST 490's bundled C sources use K&R function definitions, removed in C23.
make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS} -std=gnu11" prefix="${PREFIX}" install
