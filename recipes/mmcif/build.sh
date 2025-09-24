#!/bin/bash

set -exuo pipefail

export CMAKE_GENERATOR=Ninja

if [[ $(uname) == "Linux" ]]; then
    sed -i.bak -E \
        's|SET\(CMAKE_AR[[:space:]]+"gcc-ar"\)|SET(CMAKE_AR "$ENV{GCC_AR}")|' \
        CMakeLists.txt
fi

sed -i.bak -E \
    's|cmake_minimum_required\(VERSION .*\)|cmake_minimum_required(VERSION 3.5)|' \
    CMakeLists.txt
sed -i.bak -E \
    's|cmake_minimum_required\(VERSION .*\)|cmake_minimum_required(VERSION 3.5)|' \
    modules/pybind11/CMakeLists.txt
sed -i.bak -E \
    's|cmake_minimum_required\(VERSION .*\)|cmake_minimum_required(VERSION 3.5)|' \
    modules/pybind11_2_6_3_dev1/CMakeLists.txt

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
