#!/bin/bash

# Everything from the usual conda compiler defaults except for the rpath settings
#LDFLAGS="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined"
echo "LD_RUN_PATH: $LD_RUN_PATH"

export PLATFORM_CMAKE_EXTRAS=""
if [[ "$CXX" == *gnu-c++* ]]; then
  # For stuff like this GCC bug (especially on ARM) https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111516
  echo "Detected gcc: ignoring some compile warnings."
  export CXXFLAGS="${CXXFLAGS} -Wno-psabi"
  $CXX -dumpspecs
  export PLATFORM_CMAKE_EXTRAS="-DCMAKE_LINKER_TYPE=GOLD"
  # the gcc spec file uses push-state in the hybrid libgcc linking case, which is not supported by GOLD linker
  export LD_FLAGS="-shared-libgcc ${LD_FLAGS}" 
fi

mkdir build
cd build

# QT_HOST_PATH(_CMAKE_DIR) only needed when you actually need use the Qt MOC executable on source files with signals and slots
#  i.e. when OpenMS is built with GUI (which it is not). Note: You will need to move qt6-main from "host"
#  to "build" in your dependencies of the meta.yml recipe.
#  See also: https://stackoverflow.com/questions/39075040/cmake-cmake-automoc-in-cross-compilation
# Set INSTALL_RPATH to PREFIX such that there are no warnings during linkage fixing of conda-build
#  and make sure nothing is added by the compiler with CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH
cmake -S .. -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" -DOPENMS_GIT_SHORT_SHA1="e88b120" \
 	-DOPENMS_CONTRIB_LIBS="SILENCE_WARNING_SINCE_NOT_NEEDED" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON \
	-DHAS_XSERVER=OFF -DWITH_GUI=OFF -DENABLE_CLASS_TESTING=OFF -DENABLE_TOPP_TESTING=OFF -DBOOST_USE_STATIC=OFF -DBUILD_EXAMPLES=OFF -DENABLE_CWL=OFF -DWITH_HDF5=OFF \
	-DBoost_NO_BOOST_CMAKE=ON -DBoost_ARCHITECTURE="-x64" \
 	-DQT_HOST_PATH="${BUILD_PREFIX}" -DQT_HOST_PATH_CMAKE_DIR="${PREFIX}" \
	-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
 	${PLATFORM_CMAKE_EXTRAS}


cat src/openms/cmake_install.cmake

ninja -v -j"${CPU_COUNT}"
