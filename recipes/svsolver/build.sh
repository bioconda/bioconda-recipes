#!/bin/bash

export FFLAGS="$FFLAGS -fallow-argument-mismatch -std=legacy"
export FORTRANFLAGS="$FORTRANFLAGS -fallow-argument-mismatch -std=legacy"
export CXXFLAGS="$CXXFLAGS -std=c++11 -Wl,--allow-multiple-definition"

rm -rf build && mkdir build && pushd build
cmake .. -DSV_USE_LOCAL_VTK=1  -DCMAKE_INSTALL_PREFIX=$PREFIX -DSV_BUILD_TYPE_DIR=Release \
	-DCMAKE_BUILD_TYPE:STRING=Release

make -j 4
pushd svSolver-build
cmake -DSV_USE_SYSTEM_MPI=ON -DSV_ENABLE_DISTRIBUTION=ON -DSV_INSTALLER_TYPE=TGZ  \
      -DSV_INSTALL_HOME_DIR=${PREFIX} -DSV_INSTALL_SCRIPT_DIR="bin" -DSV_INSTALL_RUNTIME_DIR="bin" .
cpack
tar -xf svsolver-linux-x64-$(date +"%Y.%m.%d").tar.gz -C ${PREFIX} --strip-components=1
