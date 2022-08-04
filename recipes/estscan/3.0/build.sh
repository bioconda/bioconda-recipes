#!/bin/bash

# export ESTSCANDIR=$PREFIX

# Object files/libraries in wrong order => can't use --as-needed.
# (and clange does not seem to support --no-as-needed).
export LDFLAGS="${LDFLAGS//-Wl,--as-needed/}"
make maskred makesmat estscan \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
#install build_model "${PREFIX}/bin/"
install estscan "${PREFIX}/bin/"
