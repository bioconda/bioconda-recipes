#!/bin/bash

export CCACHE_DISABLE=1
export CONAN_NON_INTERACTIVE=1
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export CMAKE_C_STANDARD=23
export CMAKE_CXX_STANDARD=23
export CTEST_PARALLEL_LEVEL="${CPU_COUNT}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

scratch=$(mktemp -d)
export CONAN_HOME="${scratch}/conan"

# shellcheck disable=SC2064
trap "rm -rf '${scratch}'" EXIT

declare -a CMAKE_ARGS
if [[ "${OSTYPE}" =~ .*darwin.* ]]; then
  # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  CMAKE_PLATFORM_FLAGS+=(
    -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}"
    -DCMAKE_FIND_FRAMEWORK=NEVER
    -DCMAKE_FIND_APPBUNDLE=NEVER
  )
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

# Remove unnecessary dependencies from conanfile.py
patch conanfile.py < "${RECIPE_DIR}/conanfile.py.patch"

conan profile detect

# help CMake find the tools required to enable LTO
AR="$(which llvm-ar)"
RANLIB="$(which llvm-ranlib)"

# Build hictkpy as a shared library
HICTKPY_BUILD_SHARED_LIBS=ON

# Set CMake flags to support LTO
CMAKE_ARGS+=(-DCMAKE_CXX_COMPILER="${CXX}")
CMAKE_ARGS+=(-DCMAKE_CXX_COMPILER_AR="${AR}")
CMAKE_ARGS+=(-DCMAKE_CXX_COMPILER_RANLIB="${RANLIB}")
CMAKE_ARGS+=(-DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD}")
CMAKE_ARGS+=(-DCMAKE_C_COMPILER="${CC}")
CMAKE_ARGS+=(-DCMAKE_C_COMPILER_AR="${AR}" )
CMAKE_ARGS+=(-DCMAKE_C_COMPILER_RANLIB="${RANLIB}")
CMAKE_ARGS+=(-DCMAKE_C_STANDARD="${CMAKE_C_STANDARD}")
CMAKE_ARGS+=(-DCMAKE_LINKER_TYPE=LLD)

# See https://github.com/conda-forge/conda-forge.github.io/pull/2321
Python_INCLUDE_DIR="$("${PYTHON}" -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python_NumPy_INCLUDE_DIR="$("${PYTHON}" -c 'import numpy; print(numpy.get_include())')"

CMAKE_ARGS+=(-DPython_EXECUTABLE:PATH="${PYTHON}")
CMAKE_ARGS+=(-DPython_INCLUDE_DIR:PATH="${Python_INCLUDE_DIR}")
CMAKE_ARGS+=(-DPython_NumPy_INCLUDE_DIR="${Python_NumPy_INCLUDE_DIR}")
CMAKE_ARGS+=(-DPython3_EXECUTABLE:PATH="${PYTHON}")
CMAKE_ARGS+=(-DPython3_INCLUDE_DIR:PATH="${Python_INCLUDE_DIR}")
CMAKE_ARGS+=(-DPython3_NumPy_INCLUDE_DIR="${Python_NumPy_INCLUDE_DIR}")


echo "CFLAGS='${CFLAGS}'"
echo "CXXFLAGS='${CXXFLAGS}'"
# shellcheck disable=SC2128
echo "CMAKE_ARGS='${CMAKE_ARGS}'"

export CMAKE_ARGS CMAKE_BUILD_PARALLEL_LEVEL CFLAGS CXXFLAGS HICTKPY_BUILD_SHARED_LIBS

SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}" \
"${PYTHON}" -m pip install "${SRC_DIR}" -vv

