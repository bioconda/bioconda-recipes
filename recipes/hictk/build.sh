#!/bin/bash

export CONAN_NON_INTERACTIVE=1

export CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}
export CTEST_PARALLEL_LEVEL=${CPU_COUNT}

if [[ ${DEBUG_C} == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

scratch=$(mktemp -d)
export CONAN_HOME="$scratch/conan"

# shellcheck disable=SC2064
trap "rm -rf '$scratch'" EXIT

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  conan_profile='apple-clang'

  # https://github.com/conda/conda-build/issues/4392
  for toolname in "otool" "install_name_tool"; do
    tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname")
    mv "${tool}" "${tool}.bak"
    ln -s "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
  done
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
  conan_profile='clang'
fi

# Remember to update these profiles when bioconda's compiler toolchains are updated
mkdir -p "$CONAN_HOME/profiles/"
ln -s "${RECIPE_DIR}/conan_profiles/$conan_profile" "$CONAN_HOME/profiles/$conan_profile"

# Remove unnecessary dependencies from conanfile.py
patch conanfile.Dockerfile.py < "${RECIPE_DIR}/conanfile.Dockerfile.py.patch"

# Install header-only deps
conan install conanfile.Dockerfile.py \
       --build="*" \
       -pr:b "$conan_profile" \
       -pr:h "$conan_profile" \
       --output-folder=build/

# Add bioconda suffix to hictk version
sed -i.bak 's/set(HICTK_PROJECT_VERSION_SUFFIX "")/set(HICTK_PROJECT_VERSION_SUFFIX "bioconda")/' cmake/Versioning.cmake

CMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH:$PWD/build"

# https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process
cmake -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"   \
      -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
      -DBUILD_SHARED_LIBS=ON                   \
      -DENABLE_DEVELOPER_MODE=OFF              \
      -DHICTK_ENABLE_TESTING=ON                \
      -DHICTK_ENABLE_FUZZY_TESTING=OFF         \
      -DHICTK_BUILD_EXAMPLES=OFF               \
      -DHICTK_BUILD_BENCHMARKS=OFF             \
      -DHICTK_BUILD_TOOLS=ON                   \
      -DHICTK_ENABLE_GIT_VERSION_TRACKING=OFF  \
      -DCMAKE_INSTALL_PREFIX="$PREFIX"         \
      -DCMAKE_C_COMPILER="$CC"                 \
      -DCMAKE_CXX_COMPILER="$CXX"              \
      "${CMAKE_PLATFORM_FLAGS[@]}"             \
      -B build/                                \
      -S .

cmake --build build/

ctest --test-dir build/   \
      --output-on-failure \
      --no-tests=error    \
      --timeout 240

ls -lah build/src/hictk/hictk
md5sum build/src/hictk/hictk

cmake --install build/

ls -lah "${PREFIX}/bin"
md5sum "${PREFIX}/hictk"

"${PREFIX}/bin/hictk" --version
