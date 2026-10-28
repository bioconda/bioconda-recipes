#!/bin/bash

mkdir -p "${PREFIX}/bin"
if [[ ${target_platform} =~ osx.* ]]; then
    "${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -framework Accelerate -Isrc -o "${PREFIX}/bin/trinculo" src/trinculo.cpp
else
    "${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -DLINUX -Isrc -o "${PREFIX}/bin/trinculo" src/trinculo.cpp -llapack -lpthread
fi
