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

# QT_HOST_PATH(_CMAKE_DIR) only needed when you actually need use the Qt MOC executable on source files with signals and slots
#  i.e. when OpenMS is built with GUI (which it is not). Note: You will need to move qt6-main from "host"
#  to "build" in your dependencies of the meta.yml recipe.
#  See also: https://stackoverflow.com/questions/39075040/cmake-cmake-automoc-in-cross-compilation
# Set INSTALL_RPATH to PREFIX such that there are no warnings during linkage fixing of conda-build
#  and make sure nothing is added by the compiler with CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH.
# We set the BUILD_RPATH to the BUILD_PREFIX just to make CMake aware that the stupid compiler will add
#  this RPATH to the end of the link line (visible with -v linker flag). With this CMake can remove it at install time.
# Regarding PY_NUM_MODULES: This is a tradeoff between compile time and RAM usage.
#  We do not recommend less than 12 for current CI runners. You can try to decrease when they get more RAM
#  or faster CPUs.
cmake -S ../src/pyOpenMS -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" -DOPENMS_GIT_SHORT_SHA1="27e3601" \
 	-DOPENMS_CONTRIB_LIBS="SILENCE_WARNING_SINCE_NOT_NEEDED" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_RPATH="$BUILD_PREFIX/lib" -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH=ON \
	-DQT_HOST_PATH="${BUILD_PREFIX}" -DQT_HOST_PATH_CMAKE_DIR="${PREFIX}" \
    -DPython_EXECUTABLE="${PYTHON}" -DPython_FIND_STRATEGY="LOCATION" -DPY_NUM_MODULES=12 \
    -DNO_DEPENDENCIES=ON -DNO_SHARE=ON \
	-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
 	${PLATFORM_CMAKE_EXTRAS}

# NO_DEPENDENCIES since conda takes over re-linking etc

# limit parallel jobs to 1 for memory usage since pyopenms has huge cython generated cpp files
#cmake --build . --clean-first --target pyopenms -j 1
ninja pyopenms -j"${CPU_COUNT}"

echo "wheels are in `find . | grep whl`"  >&2
${PYTHON} -m pip install ./pyOpenMS/dist/*.whl --no-build-isolation --no-deps --no-cache-dir --use-pep517 --no-binary=pyopenms -vvv
