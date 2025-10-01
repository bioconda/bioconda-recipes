#!/bin/bash

set -xe

export CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=${PREFIX}"
export CMAKE_ARGS="${CMAKE_ARGS} -DINSTALL_CMAKE_DIR=${PREFIX}/share/cmake/Modules"

# Get path to Python interpreter
export PYTHON_EXECUTABLE=$(${PYTHON} -c "import sys; print(sys.executable, end='')")

# Create build directory
mkdir build

# Configure build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
    -DPYTHON_EXECUTABLE="$(which ${PYTHON})" \
    -Dpybind11_DIR="${PREFIX}/share/cmake/pybind11" \
    -DCMAKE_MODULE_PATH="${PREFIX}/share/cmake/Modules" \
    ..

# Build native extension
make VERBOSE=1

# Build wheel
${PYTHON} -m build --no-isolation

# Install wheel
${PYTHON} -m pip install dist/*.whl --no-deps --ignore-installed -vv
