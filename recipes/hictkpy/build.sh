#!/bin/bash

export CONAN_NON_INTERACTIVE=1

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"

scratch=$(mktemp -d)
export CONAN_HOME="${scratch}/conan"

# shellcheck disable=SC2064
trap "rm -rf '${scratch}'" EXIT

declare -a CMAKE_ARGS
if [[ "${OSTYPE}" =~ .*darwin.* ]]; then
  # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  CMAKE_ARGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  # Workaround missing LLVMgold.so on Linux (setting CMAKE_LINKER_TYPE does not seem to work)
  export CXXFLAGS="${CXXFLAGS} -fuse-ld=lld"
fi

# Remove unnecessary dependencies from conanfile.py
patch conanfile.py < "${RECIPE_DIR}/conanfile.py.patch"

conan profile detect

# Build hictkpy as a shared library
HICTKPY_BUILD_SHARED_LIBS=ON

# See https://github.com/conda-forge/conda-forge.github.io/pull/2321
Python_INCLUDE_DIR="$("${PYTHON}" -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python_NumPy_INCLUDE_DIR="$("${PYTHON}" -c 'import numpy; print(numpy.get_include())')"

CMAKE_ARGS+=(-DPython_EXECUTABLE:PATH="${PYTHON}")
CMAKE_ARGS+=(-DPython_INCLUDE_DIR:PATH="${Python_INCLUDE_DIR}")
CMAKE_ARGS+=(-DPython_NumPy_INCLUDE_DIR="${Python_NumPy_INCLUDE_DIR}")
CMAKE_ARGS+=(-DPython3_EXECUTABLE:PATH="${PYTHON}")
CMAKE_ARGS+=(-DPython3_INCLUDE_DIR:PATH="${Python_INCLUDE_DIR}")
CMAKE_ARGS+=(-DPython3_NumPy_INCLUDE_DIR="${Python_NumPy_INCLUDE_DIR}")

# shellcheck disable=SC2001,SC2178
CMAKE_ARGS="$(echo "${CMAKE_ARGS[*]}" | sed 's/-DCMAKE_LINKER[^ ]\+//')"

echo "CFLAGS='${CFLAGS}'"
echo "CXXFLAGS='${CXXFLAGS}'"
# shellcheck disable=SC2128
echo "CMAKE_ARGS='${CMAKE_ARGS}'"

export CMAKE_ARGS CMAKE_BUILD_PARALLEL_LEVEL CFLAGS CXXFLAGS HICTKPY_BUILD_SHARED_LIBS

# Workaround UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position 2: invalid continuation byte
# when trying to map Python types to C++ types. See https://github.com/paulsengroup/hictkpy/pull/179
patch src/type.cpp < "${RECIPE_DIR}/type.cpp.patch"

SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}" \
"${PYTHON}" -m pip install "${SRC_DIR}" -vv

