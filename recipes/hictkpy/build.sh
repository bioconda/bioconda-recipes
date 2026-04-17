#!/bin/bash

set -e
set -u
set -o pipefail


export CCACHE_DISABLE=1
export CONAN_NON_INTERACTIVE=1
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export CTEST_PARALLEL_LEVEL="${CPU_COUNT}"

scratch=$(mktemp -d)
export CONAN_HOME="${scratch}/conan"

# shellcheck disable=SC2064
trap "rm -rf '${scratch}'" EXIT

# Remove unnecessary dependencies from conanfile.py
patch conanfile.py < "${RECIPE_DIR}/conanfile.py.patch"

# Build hictkpy as a shared library
export HICTKPY_BUILD_SHARED_LIBS=ON
export HICTKPY_OSX_DEPLOYMENT_TARGET=10.15

if [[ "${OSTYPE}" =~ .*darwin.* ]]; then
  export CMAKE_SYSTEM_NAME=Darwin
else
  export CMAKE_SYSTEM_NAME=Linux
fi

SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}" \
"${PYTHON}" -m pip install "${SRC_DIR}" -vv \
  --config-settings="cmake.define.CMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/toolchain.cmake"
