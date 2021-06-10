#!/bin/bash

cd nano_src
make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS}"
install -d "${PREFIX}/bin"
install nanoblaster "${PREFIX}/bin/"
