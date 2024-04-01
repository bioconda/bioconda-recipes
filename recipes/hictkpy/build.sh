#!/bin/bash

# export CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}

scratch=$(mktemp -d)
export CONAN_HOME="$scratch/conan"

# shellcheck disable=SC2064
trap "rm -rf '$scratch'" EXIT

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.15  # Required to use std::filesystem
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  conan_profile='apple-clang'
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
  conan_profile='gcc'
fi

# Remember to update these profiles when bioconda's compiler toolchains are updated
mkdir -p "$CONAN_HOME/profiles/"
ln -s "${RECIPE_DIR}/conan_profiles/$conan_profile" "$CONAN_HOME/profiles/default"

# explicitly set CMAKE_OSX_DEPLOYMENT_TARGET
patch CMakeLists.txt < "${RECIPE_DIR}/CMakeLists.txt.patch"

# Remove unnecessary dependencies from conanfile.txt
patch conanfile.txt < "${RECIPE_DIR}/conanfile.txt.patch"

# Build hictkpy as a shared library
patch pyproject.toml < "${RECIPE_DIR}/pyproject.toml.patch"

CMAKE_ARGS+=" -DPython_EXECUTABLE=$PYTHON"

echo "$CMAKE_ARGS"
export CMAKE_ARGS

SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION" \
"$PYTHON" -m pip install "$SRC_DIR" -vv

