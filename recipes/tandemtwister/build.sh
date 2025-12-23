#!/bin/bash

# Build TandemTwister
cd ${SRC_DIR}

echo "Building TandemTwister..."
echo "Working directory: $(pwd)"
echo "SRC_DIR: ${SRC_DIR}"
echo "CXX: ${CXX}"
echo "CXXFLAGS: ${CXXFLAGS}"
echo "LDFLAGS: ${LDFLAGS}"
echo "PREFIX: ${PREFIX}"
echo "CONDA_PREFIX: ${CONDA_PREFIX}"

# Show directory contents to verify source was cloned
echo "Source directory contents:"
ls -la

# Set CONDA_PREFIX to PREFIX for the Makefile (conda sets PREFIX, Makefile expects CONDA_PREFIX)
export CONDA_PREFIX="${PREFIX}"

# Set up library paths
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export CPATH="${PREFIX}/include:${CPATH}"


make -j${CPU_COUNT} CXX="${CXX}"

# Verify the executable was built
if [ -f "tandemtwister" ]; then
    echo "Build successful: tandemtwister created"
    ls -lh tandemtwister
else
    echo "ERROR: Build failed - tandemtwister not found"
    exit 1
fi

# Install to conda prefix
mkdir -p ${PREFIX}/bin
install -m 755 tandemtwister ${PREFIX}/bin/

echo "Installation complete: ${PREFIX}/bin/tandemtwister"