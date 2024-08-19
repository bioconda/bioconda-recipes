#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PREFIX}/lib
make CC="${CXX}"

mkdir -p ${PREFIX}/bin
cp miniprot_boundary_scorer ${PREFIX}/bin