#!/bin/bash

set -x -e

export LD_LIBRARY_PATH="${PREFIX}/lib"
make all PREFIX=${PREFIX}
make install PREFIX=${PREFIX}
make test

