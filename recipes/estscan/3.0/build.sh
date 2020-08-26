#!/bin/bash

# export ESTSCANDIR=$PREFIX

# Set -Wl,-no-as-needed due to wrong order of obj and lib files.
make maskred makesmat estscan \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -Wl,-no-as-needed"

install -d "${PREFIX}/bin"
#install build_model "${PREFIX}/bin/"
install estscan "${PREFIX}/bin/"
