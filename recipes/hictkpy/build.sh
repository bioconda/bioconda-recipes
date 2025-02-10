#!/bin/bash

CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}

scratch=$(mktemp -d)
export CONAN_HOME="$scratch/conan"

# shellcheck disable=SC2064
trap "rm -rf '$scratch'" EXIT

if [[ ${HOST} =~ .*darwin.* ]]; then
  if [[ "$OSX_ARCH" == 'x86_64' ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
    CFLAGS+=' -D_LIBCPP_DISABLE_AVAILABILITY'
    CXXFLAGS+=' -D_LIBCPP_DISABLE_AVAILABILITY'
  fi
  CMAKE_ARGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
  conan_profile='apple-clang'
else
  # Workaround missing LLVMgold.so on Linux
  CMAKE_ARGS+=' -DCMAKE_LINKER_TYPE=LLD'
  CMAKE_ARGS+=" -DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake"
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

CMAKE_ARGS+=" -DPython_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS+=" -DPython_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"
CMAKE_ARGS+=" -DPython_NumPy_INCLUDE_DIR=${Python_NumPy_INCLUDE_DIR}"
CMAKE_ARGS+=" -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS+=" -DPython3_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"
CMAKE_ARGS+=" -DPython3_NumPy_INCLUDE_DIR=${Python_NumPy_INCLUDE_DIR}"

echo "CFLAGS='$CFLAGS'"
echo "CXXFLAGS='$CXXFLAGS'"
echo "CMAKE_ARGS='$CMAKE_ARGS'"

export CMAKE_ARGS CMAKE_BUILD_PARALLEL_LEVEL CFLAGS CXXFLAGS

SETUPTOOLS_SCM_PRETEND_VERSION="$PKG_VERSION" \
"$PYTHON" -m pip install "$SRC_DIR" -vv

