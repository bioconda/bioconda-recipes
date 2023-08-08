#!/bin/bash

export CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}

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

# Remove unnecessary dependencies from conanfile.txt
patch conanfile.txt < "${RECIPE_DIR}/conanfile.txt.patch"

# Install header-only deps
conan install conanfile.txt \
       --build="*" \
       --output-folder=build/

# Help CMake find_package(Python) finding Python headers
PYTHON_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"

CMAKE_ARGS="-DCMAKE_PREFIX_PATH=$PWD/build"
CMAKE_ARGS+=" -DPython_INCLUDE_DIR=$PYTHON_INCLUDE_DIR"
CMAKE_ARGS+=" ${CMAKE_PLATFORM_FLAGS[*]}"

export CMAKE_ARGS

HICTKPY_SETUP_SKIP_CONAN=1 \
"$PYTHON" -m pip install . -v

python -m site

ls -lah /opt/conda/conda-bld/hictkpy_*/_build_env/lib/python3.11/site-packages
ls -lah /opt/conda/conda-bld/hictkpy_*/_build_env/lib/python3.11/site-packages/hictkpy

"$PYTHON" -c 'import hictkpy; print(hictkpy.__version__)'
