#!/bin/bash

export PLATFORM_CMAKE_EXTRAS=""
if [[ "$CXX" == *gnu-c++* ]]; then
  # For stuff like this GCC bug (especially on ARM) https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111516
  echo "Detected gcc: ignoring some compile warnings."
  export CXXFLAGS="${CXXFLAGS} -Wno-psabi"

  # If you want GOLD linker (which is faster), try the following next two exports.
  #export PLATFORM_CMAKE_EXTRAS="-DCMAKE_LINKER_TYPE=GOLD"
  # the gcc spec file uses push-state in the hybrid libgcc linking case, which is not supported by GOLD linker
  #export LDFLAGS="-shared-libgcc ${LDFLAGS}"
  # Debug if you see what kind of nonsense gcc does under the hood with rpaths
  #export LDFLAGS="-v ${LDFLAGS}"
fi

mkdir build
cd build

# Set INSTALL_RPATH to PREFIX such that there are no warnings during linkage fixing of conda-build
#  and make sure nothing is added by the compiler with CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH.
# We set the BUILD_RPATH to the BUILD_PREFIX just to make CMake aware that the stupid compiler will add
#  this RPATH to the end of the link line (visible with -v linker flag). With this CMake can remove it at install time.
cmake -S .. -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" -DOPENMS_GIT_SHORT_SHA1="e88b120" \
 	-DOPENMS_CONTRIB_LIBS="SILENCE_WARNING_SINCE_NOT_NEEDED" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_RPATH="$BUILD_PREFIX/lib" -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON \
	-DHAS_XSERVER=OFF -DWITH_GUI=OFF -DENABLE_CLASS_TESTING=OFF -DENABLE_TOPP_TESTING=OFF -DBOOST_USE_STATIC=OFF -DBUILD_EXAMPLES=OFF -DENABLE_CWL=OFF -DWITH_HDF5=OFF \
	-DWITH_THERMO_RAW=OFF \
	-DWITH_PARQUET=ON -DARROW_USE_STATIC=OFF \
	-DBoost_NO_BOOST_CMAKE=ON -DBoost_ARCHITECTURE="-x64" \
	-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
 	${PLATFORM_CMAKE_EXTRAS}


ninja -j"${CPU_COUNT}"
