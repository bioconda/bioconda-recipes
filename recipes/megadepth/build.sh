#!/usr/bin/env bash
#based in part on https://github.com/AnacondaRecipes/libnetcdf-feedstock/blob/master/recipe/build.sh
#and on the WiggleTools conda build script: 
#https://github.com/bioconda/bioconda-recipes/blob/master/recipes/wiggletools/build.sh
set -ex

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

if [[ ${DEBUG_C} == yes ]]; then
      CMAKE_BUILD_TYPE=Debug
else
      CMAKE_BUILD_TYPE=Release
fi

#build dynamic by default
bc="megadepth_dynamic"

cd $SRC_DIR
mkdir -p include lib
cp -r $PREFIX/include/* include/
cp -r $PREFIX/lib/* lib/

ln -fs ${RECIPE_DIR}/CMakeLists.txt ./

DR=build-release-temp
mkdir -p ${DR}
pushd ${DR}
cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PREFIX} ${CMAKE_PLATFORM_FLAGS[@]} ..
make ${bc}
popd
cp $DR/${bc} $PREFIX/bin/megadepth
