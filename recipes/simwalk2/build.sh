#!/bin/bash

install -d "${PREFIX}/bin"
# segfaults with -fopenmp
"${FC}" ${FFLAGS/-fopenmp/} ${CPPFLAGS} ${LDFLAGS} \
    -o "${PREFIX}/bin/simwalk2" CODE/nomendel.f CODE/simwalk2.f -lgfortran -lm
