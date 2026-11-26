#!/bin/bash

if [[ "$CXX" == *gnu-c++* ]]; then
  export CXXFLAGS="${CXXFLAGS} -Wno-psabi"
fi

# The source tarball already contains an empty build/ directory.
mkdir -p build
cd build

# Split mode needs the nanobind-backend package, which is not on conda-forge.
cmake -S ../src/pyOpenMS -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_RPATH="$BUILD_PREFIX/lib" -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON \
	-DPython_EXECUTABLE="${PYTHON}" -DPython_FIND_STRATEGY="LOCATION" \
	-DPYOPENMS_SPLIT_MODE=OFF -DNO_DEPENDENCIES=ON -DNO_SHARE=ON -DPYOPENMS_GENERATE_STUBS=ON \
	-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}

ninja pyopenms -j3

# Stripped modules break conda-build on osx-64.
STRIP_ARG="--strip"
if [[ "$target_platform" == osx-* ]]; then
  STRIP_ARG=""
fi
SITE_PACKAGES=$(${PYTHON} -c "import sysconfig; print(sysconfig.get_path('platlib'))")
cmake --install . --component python_modules --prefix "${SITE_PACKAGES}" ${STRIP_ARG}

# pyopenms.__version__ reads the version from this dist-info.
DIST_INFO="pyopenms-${PKG_VERSION}.dist-info"
mkdir -p "${SITE_PACKAGES}/${DIST_INFO}"
cat > "${SITE_PACKAGES}/${DIST_INFO}/METADATA" <<EOF
Metadata-Version: 2.1
Name: pyopenms
Version: ${PKG_VERSION}
Summary: Python wrapper for C++ LC-MS library OpenMS
Home-page: https://openms.de
License: BSD-3-Clause
Requires-Python: >=3.11
EOF
echo "conda" > "${SITE_PACKAGES}/${DIST_INFO}/INSTALLER"
(
  cd "${SITE_PACKAGES}"
  find pyopenms "${DIST_INFO}" -type f ! -name RECORD | LC_ALL=C sort | sed 's/$/,,/'
  echo "${DIST_INFO}/RECORD,,"
) > "${SITE_PACKAGES}/${DIST_INFO}/RECORD"
