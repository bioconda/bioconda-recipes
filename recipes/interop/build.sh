#!/bin/bash
echo "DEBUG START"
ls -l
echo "DEBUG END"
mkdir build
cd build
cmake ../interop
cmake --build .
