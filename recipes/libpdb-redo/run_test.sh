#!/bin/bash

set -exo pipefail

test -d ${PREFIX}/include/pdb-redo
test -f ${PREFIX}/lib/libpdb-redo${SHLIB_EXT}
