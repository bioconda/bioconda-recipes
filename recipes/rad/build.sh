#!/usr/bin/env bash
set -euo pipefail

if [[ `uname` == "Darwin" ]]; then
  # std::filesystem needs a macOS 10.15+ deployment target; force CMake to use
  # the conda target (raised to 10.15 for osx-64 via conda_build_config.yaml).
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-10.15}"
else
  export CONFIG_ARGS=""
fi

# configure CMake: install into $PREFIX (v1.0.0+ adds real install() rules that
# install the binary, the bin/rad wrapper, and resources/ to share/rad).
# ${CMAKE_ARGS} carries the conda toolchain settings, incl. the macOS
# deployment target + SDK sysroot, which std::filesystem availability depends on.
cmake -S . -B build ${CMAKE_ARGS:-} -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
  ${CONFIG_ARGS}

cmake --build build --clean-first -j "${CPU_COUNT}"
cmake --install build --prefix "${PREFIX}"
