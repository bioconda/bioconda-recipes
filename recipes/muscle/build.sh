#!/bin/bash
set -e

mkdir -p ${PREFIX}/bin
cd src || exit 1
cp ${RECIPE_DIR}/vcxproj_make.py .
chmod +x vcxproj_make.py

if [ "$(uname)" == "Darwin" ]; then
    # macOS
    ./vcxproj_make.py --openmp --cppcompiler g++-11
else
    # Linux
    ./vcxproj_make.py --openmp
fi

# Verify binary exists and is executable
if [ ! -f ../bin/muscle ]; then
    echo "Error: muscle binary not found"
    exit 1
fi

cp ../bin/muscle ${PREFIX}/bin/muscle
