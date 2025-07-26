#!/bin/bash

# Add the library path to the LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PREFIX}/lib

# Ensure the lib directory exists
mkdir -p "${SRC_DIR}"/lib

# Generate the SWIG files
echo "Generating SWIG files..."
swig -c++ -python -outdir "${SRC_DIR}"/lib -I"${SRC_DIR}"/include -I"${PREFIX}"/include -o "${SRC_DIR}"/src/lrst_wrap.cpp "${SRC_DIR}"/src/lrst.i

# Generate the shared library
echo "Building the shared library..."
$PYTHON setup.py -I"${PREFIX}"/include -L"${PREFIX}"/lib install

# Create the src directory
mkdir -p "${PREFIX}"/src

# Copy source files to the bin directory
echo "Copying source files..."
cp -r "${SRC_DIR}"/src/*.py "${PREFIX}"/bin

# Copy the SWIG generated library to the lib directory
echo "Copying SWIG generated library..."
cp -r "${SRC_DIR}"/lib/*.py "${PREFIX}"/lib
cp -r "${SRC_DIR}"/lib/*.so "${PREFIX}"/lib

echo "Build complete."
