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

# The 3.6.0 source tarball has no top-level folder and ships an empty build/ directory:
# a plain "mkdir build" fails under conda-build's errexit.
mkdir -p build
cd build

# pyOpenMS 3.6.0 is built with nanobind; src/pyOpenMS is configured standalone against the
# installed libopenms (find_package(OpenMS)), as the wheel workflow does through py-build-cmake.
# py-build-cmake itself cannot be used: pyproject.toml asks for py-build-cmake~=0.5.1 (conda-forge
# has 0.4.3) and for a cp311-abi3 wheel.
# Set INSTALL_RPATH to PREFIX such that there are no warnings during linkage fixing of conda-build
#  and make sure nothing is added by the compiler with CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH.
# We set the BUILD_RPATH to the BUILD_PREFIX just to make CMake aware that the stupid compiler will add
#  this RPATH to the end of the link line (visible with -v linker flag). With this CMake can remove it at install time.
# PYOPENMS_SPLIT_MODE=OFF: the default split mode (stable ABI) makes every module import the
#  nanobind_backend module of the nanobind-backend package at load time; that package is on PyPI
#  only, not on conda-forge. Conda builds one package per Python version anyway.
# NO_SHARE=ON: the share data comes with libopenms. NO_DEPENDENCIES=ON (the 3.6.0 default): conda relinks.
# PYOPENMS_GENERATE_STUBS (default ON) needs nanobind importable from ${PYTHON}; it imports the built
#  package during the build. Configure with -DPYOPENMS_GENERATE_STUBS=OFF to build without .pyi stubs.
# Removed since 3.5.0: PY_NUM_MODULES (Cython), OPENMS_CONTRIB_LIBS, QT_HOST_PATH*, OPENMS_GIT_SHORT_* (unused here).
cmake -S ../src/pyOpenMS -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_RPATH="$BUILD_PREFIX/lib" -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON \
	-DPython_EXECUTABLE="${PYTHON}" -DPython_FIND_STRATEGY="LOCATION" \
	-DPYOPENMS_SPLIT_MODE=OFF -DNO_DEPENDENCIES=ON -DNO_SHARE=ON -DPYOPENMS_GENERATE_STUBS=ON \
	-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
 	${PLATFORM_CMAKE_EXTRAS}

# 15 nanobind extension modules. -j3 kept from 3.5.0 (validated in the OpenMS nightly Bioconda build
# of 3.6.0dev: about 6 minutes per build on linux-64).
ninja pyopenms -j3

# The CMake component python_modules is what the wheel contains (install_components in pyproject.toml):
# the extension modules, the Python files, the .pyi stubs and py.typed.
SITE_PACKAGES=$(${PYTHON} -c "import sysconfig; print(sysconfig.get_path('platlib'))")
cmake --install . --component python_modules --prefix "${SITE_PACKAGES}" --strip

# pyopenms.__version__ is importlib.metadata.version("pyopenms"), which needs a dist-info
# (without one it reports "0+unknown", as the 3.6.0dev nightly packages do).
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
