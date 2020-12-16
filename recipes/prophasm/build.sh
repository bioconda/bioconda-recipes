#!/bin/bash

make CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install prophasm "${PREFIX}/bin/"
