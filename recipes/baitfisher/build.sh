#!/bin/bash

make CPP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"

install -d "${PREFIX}/bin"
install BaitFisher-v1.2.7 "${PREFIX}/bin/BaitFisher"
install BaitFilter-v1.0.5 "${PREFIX}/bin/BaitFilter"
