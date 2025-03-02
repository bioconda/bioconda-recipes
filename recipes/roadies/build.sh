#!/bin/bash

# Debugging: Print current directory and list its contents
echo "Current directory: $(pwd)"
echo "Contents:"
ls -al

mkdir -p $PREFIX/ROADIES

# Download and setup ASTER repository if not already done
if [ ! -d "ASTER-Linux" ]; then
    wget -q https://github.com/chaoszhang/ASTER/archive/refs/heads/Linux.zip -O Linux.zip
    unzip -q Linux.zip
    cd ASTER-Linux
    $CXX -D CASTLES -std=gnu++11 -march=native -Ofast -pthread src/astral-pro.cpp -o bin/astral-pro3
    cd ..
fi

# Build sampling code
if [ ! -d "workflow/scripts/sampling/build" ]; then
    cd workflow/scripts/sampling
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
    make
    cd ../../../..
fi

# Download and setup LASTZ if not already done
if [ ! -d "workflow/scripts/lastz_32" ]; then
    cd workflow/scripts
    wget https://github.com/lastz/lastz/archive/refs/heads/master.zip
    unzip master.zip
    cd lastz-master/src/
    make CC="${CC}" CXX="${CXX}" lastz_32 flagsFor32="-Dmax_sequence_index=63 -Dmax_malloc_index=40 -Ddiag_hash_size=4194304" definedForAll="-Wall -Wextra -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE"
    make install_32
    cp lastz_32 ../../
    cd ../../../../
fi

mkdir -p pasta

# Debugging: Print current directory and list its contents before copying
echo "Current directory before copying ROADIES: $(pwd)"
echo "Contents before copying ROADIES:"
ls -al

# Copy the entire ROADIES directory to the PREFIX directory
cp -r . $PREFIX/ROADIES

# Debugging: Verify the contents of the PREFIX directory
echo "Contents of PREFIX:"
ls -al $PREFIX