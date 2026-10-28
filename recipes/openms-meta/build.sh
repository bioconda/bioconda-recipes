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

# Release tarballs carry no git metadata (3.6.0 even ships an empty .git/), so with git tracking on,
# OpenMS would call itself "3.6.0-pre-exported-<date>". Set the refspec and revision explicitly;
# the v<version> refspec makes VersionInfo report the plain version. Dev builds come from a git clone.
if [[ "${PKG_VERSION}" == *dev* ]]; then
  export GIT_CMAKE_ARGS=""
else
  export GIT_CMAKE_ARGS="-DGIT_TRACKING=OFF -DOPENMS_GIT_SHORT_REFSPEC=v${PKG_VERSION} -DOPENMS_GIT_SHORT_SHA1=5d5cbff"
fi

# The 3.6.0 source tarball has no top-level folder and ships an empty build/ directory:
# a plain "mkdir build" fails under conda-build's errexit.
mkdir -p build
cd build

# Set INSTALL_RPATH to PREFIX such that there are no warnings during linkage fixing of conda-build
#  and make sure nothing is added by the compiler with CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH.
# We set the BUILD_RPATH to the BUILD_PREFIX just to make CMake aware that the stupid compiler will add
#  this RPATH to the end of the link line (visible with -v linker flag). With this CMake can remove it at install time.
# OpenMS 3.6.0 would download at configure time: openms-thermo-bridge (+ Thermo assemblies, needs the .NET SDK)
#  with WITH_THERMO_RAW (default ON), opentims with WITH_OPENTIMS (default ON), HiGHS if no LP solver is found
#  (LP_SOLVER=AUTO), yaml-cpp >= 0.9 with ENABLE_TDL (conda-forge has 0.8), wnet* with WITH_WNETALIGN.
#  All of them are off or pinned to the conda packages here.
# Arrow/Parquet are always required since 3.6.0 (WITH_PARQUET is gone); conda-forge ships shared libraries.
# Removed since 3.5.0 (they now only cause unused-variable warnings or, for OPENMS_CONTRIB_LIBS, the deprecated
#  contrib code path): OPENMS_CONTRIB_LIBS, BOOST_USE_STATIC, WITH_PARQUET, ENABLE_CWL (never an option),
#  BUILD_EXAMPLES, Boost_NO_BOOST_CMAKE/Boost_ARCHITECTURE (Boost is found in CONFIG mode), QT_HOST_PATH* (no Qt).
cmake -S .. -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	${GIT_CMAKE_ARGS} \
	-DOPENMS_USE_VCPKG=OFF \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_RPATH="$BUILD_PREFIX/lib" -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON \
	-DHAS_XSERVER=OFF -DWITH_GUI=OFF -DENABLE_DOCS=OFF -DENABLE_CLASS_TESTING=OFF -DENABLE_TOPP_TESTING=OFF -DWITH_HDF5=OFF \
	-DARROW_USE_STATIC=OFF -DLP_SOLVER=COIN \
	-DWITH_THERMO_RAW=OFF -DWITH_OPENTIMS=OFF -DWITH_WNETALIGN=OFF -DENABLE_TDL=OFF \
	-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
 	${PLATFORM_CMAKE_EXTRAS}


ninja -j"${CPU_COUNT}"
