#!/bin/bash

make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install str8rzr "${PREFIX}/bin/"
