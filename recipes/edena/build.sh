#!/bin/bash

make CCC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install bin/edena "${PREFIX}/bin/"
