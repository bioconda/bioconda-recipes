#!/bin/bash

mkdir build
cd build
cmake ..
make CC=$CC
