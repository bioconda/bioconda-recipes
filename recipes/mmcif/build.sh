#!/bin/bash

set -exuo pipefail

export CMAKE_GENERATOR=Ninja

# Disable LTO
sed -i.bak 's|-flto||g' CMakeLists.txt

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
