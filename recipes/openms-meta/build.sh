#!/bin/bash

if [[ "$CC" == *gcc* ]]; then
  # For stuff like this GCC bug (especially on ARM) https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111516
  echo "Detected gcc: ignoring some compile warnings."
  export CXXFLAGS="${CXXFLAGS} -Wno-psabi"
fi

mkdir build
cd build

# Skip adding any rpath. Conda binary_relocation tools will do it.
cmake -S .. -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" -DOPENMS_GIT_SHORT_SHA1="e88b120" \
 	-DOPENMS_CONTRIB_LIBS="SILENCE_WARNING_SINCE_NOT_NEEDED" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_SKIP_RPATH=On \
	-DHAS_XSERVER=OFF -DENABLE_TUTORIALS=OFF -DENABLE_CLASS_TESTING=OFF -DENABLE_TOPP_TESTING=Off -DWITH_GUI=OFF -DBOOST_USE_STATIC=OFF \
	-DBoost_NO_BOOST_CMAKE=ON -DBoost_ARCHITECTURE="-x64" -DQT_HOST_PATH="${BUILD_PREFIX}" -DQT_HOST_PATH_CMAKE_DIR="${PREFIX}" \
	-DBUILD_EXAMPLES=OFF -DENABLE_CWL_GENERATION=OFF -DWITH_HDF5=OFF -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}

ninja -j"${CPU_COUNT}"
