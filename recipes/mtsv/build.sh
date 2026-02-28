#!/bin/bash -e

"${CXX}" ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} \
    -std=c++11 -pthread \
    mtsv/mtsv_prep/taxidtool.cpp -o mtsv-db-build

mkdir -p "${PREFIX}/bin"
cp mtsv-db-build "${PREFIX}/bin/"

"${PYTHON}" -m pip install . --no-deps -vv
