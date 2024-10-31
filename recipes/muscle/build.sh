#!/bin/bash

mkdir -p ${PREFIX}/bin
cd src
cp ${RECIPE_DIR}/vcxproj_make.py .
chmod +x vcxproj_make.py

if [ "$(uname)" == "Darwin" ]; then
    # macOS
    ./vcxproj_make.py --openmp --cppcompiler g++-11
else
    # Linux
    ./vcxproj_make.py --openmp
fi

cp ../bin/muscle "$PREFIX"/bin/muscle
