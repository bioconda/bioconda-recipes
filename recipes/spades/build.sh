#!/bin/bash

set -e -o pipefail -x

./spades_compile.sh -DSPADES_USE_JEMALLOC:BOOL=OFF


