#!/bin/bash

# Create the src directory
mkdir -p "${PREFIX}"/src

# Add the library path to the LD_LIBRARY_PATH
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
sed -i.bak 's|-std=c++11|-std=c++14|' setup.py
rm -rf *.bak

# Build the C++ library
make CXX="${CXX}" -j"${CPU_COUNT}"

# Generate the shared library
${PYTHON} setup.py -I"${PREFIX}/include" -L"${PREFIX}/lib" install

# Copy source files to the bin directory
cp -rf "${SRC_DIR}"/src/*.py "${PREFIX}"/bin

# Copy the SWIG generated library to the lib directory
cp -rf "${SRC_DIR}"/lib/*.py "${PREFIX}"/lib
cp -rf "${SRC_DIR}"/lib/*.so "${PREFIX}"/lib
