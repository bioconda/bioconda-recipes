# Add more verbose error checking to build.sh
#!/bin/bash
set -ex

# Print detailed environment information
echo "Environment Variables:"
env | sort

# Compiler and build tool versions
echo "Compiler Version:"
$CXX --version

echo "CMake Version:"
cmake --version

echo "GCC Version:"
gcc --version

# Create build directory
mkdir -p build && cd build

# Detailed CMake configuration
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCONDA_BUILD=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DARCH_NATIVE=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    2>&1 | tee cmake_config.log

# Check CMake configuration log
cat cmake_config.log

# Print build directory contents
echo "Build Directory Contents:"
ls -R

# Build with maximum verbosity
make VERBOSE=1 2>&1 | tee build_log.txt

# Check build log
cat build_log.txt

# Install
make install
