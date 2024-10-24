#!/bin/bash

CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}

scratch=$(mktemp -d)
export CONAN_HOME="$scratch/conan"

# shellcheck disable=SC2064
trap "rm -rf '$scratch'" EXIT

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
  CXXFLAGS+=" -D_LIBCPP_DISABLE_AVAILABILITY"
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  conan_profile='apple-clang'
else
  # Workaround missing LLVMgold.so on Linux
  CXXFLAGS+=" -fuse-ld=lld -Wno-unused-command-line-argument"
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
  conan_profile='clang'
fi

# Remember to update these profiles when bioconda's compiler toolchains are updated
mkdir -p "$CONAN_HOME/profiles/"
ln -s "${RECIPE_DIR}/conan_profiles/$conan_profile" "$CONAN_HOME/profiles/default"

# Remove unnecessary dependencies from conanfile.py
patch conanfile.py < "${RECIPE_DIR}/conanfile.py.patch"

# Build hictkpy as a shared library
patch pyproject.toml < "${RECIPE_DIR}/pyproject.toml.patch"

# See https://github.com/conda-forge/conda-forge.github.io/pull/2321
Python_INCLUDE_DIR="$("$PYTHON" -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python_NumPy_INCLUDE_DIR="$("$PYTHON" -c 'import numpy; print(numpy.get_include())')"

declare -a CMAKE_ARGS
CMAKE_ARGS+=("-DPython_EXECUTABLE:PATH=${PYTHON}")
CMAKE_ARGS+=("-DPython_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}")
CMAKE_ARGS+=("-DPython_NumPy_INCLUDE_DIR=${Python_NumPy_INCLUDE_DIR}")
CMAKE_ARGS+=("-DPython3_EXECUTABLE:PATH=${PYTHON}")
CMAKE_ARGS+=("-DPython3_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}")
CMAKE_ARGS+=("-DPython3_NumPy_INCLUDE_DIR=${Python_NumPy_INCLUDE_DIR}")

CMAKE_ARGS="${CMAKE_ARGS[*]}"
CMAKE_PLATFORM_FLAGS="${CMAKE_PLATFORM_FLAGS[*]}"

echo "$CMAKE_ARGS"
echo "$CMAKE_CMAKE_PLATFORM_FLAGS"

export CMAKE_ARGS CMAKE_BUILD_PARALLEL_LEVEL CMAKE_PLATFORM_FLAGS CXXFLAGS

SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION" \
"$PYTHON" -m pip install "$SRC_DIR" -vv

