#!/bin/bash
set -e

mkdir -p ${PREFIX}/bin
cd src || exit 1
echo "0" > gitver.txt

cp ${RECIPE_DIR}/vcxproj_make.py .
chmod +x vcxproj_make.py

if [ "$(uname)" == "Darwin" ]; then
    ./vcxproj_make.py --openmp --cppcompiler ${CXX}
else
    ./vcxproj_make.py --openmp --cppcompiler ${CXX} --ccompiler ${GCC}
fi

# Verify binary exists and is executable
if [ ! -f ../bin/reseek ]; then
    echo "Error: reseek binary not found"
    exit 1
fi

cp ../bin/muscle ${PREFIX}/bin/reseek
