#!/bin/bash

BUILD_FOLDER="${PREFIX}/build"

mkdir "${BUILD_FOLDER}"
cd "${BUILD_FOLDER}"
cmake
make
