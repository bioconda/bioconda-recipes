#!/bin/bash
make -j CXX="${CXX} ${CXXFLAGS} -std=c++03 ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install mapDIA "${PREFIX}/bin/mapDIA"
