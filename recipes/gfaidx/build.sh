#!/usr/bin/env bash
set -euo pipefail

cmake -S . -B build ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --prefix "${PREFIX}"
