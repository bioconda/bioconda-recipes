#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

bash spades_compile.sh -rj8
