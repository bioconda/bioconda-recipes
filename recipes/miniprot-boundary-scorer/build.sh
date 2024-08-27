#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC="${CXX}" LDFLAGS="-L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
cp miniprot_boundary_scorer ${PREFIX}/bin