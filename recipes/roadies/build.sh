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
    $CXX -D CASTLES -std=gnu++11 -march=native -Ofast -pthread src/astral-pro.cpp -o bin/astral-pro2
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