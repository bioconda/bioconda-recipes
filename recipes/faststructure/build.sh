#!/bin/bash

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Build vars
cd vars
${PYTHON} setup.py build_ext --inplace
cd ..

# Build main
${PYTHON} setup.py build_ext --inplace
cp -f vars/*.so ./

# Make scripts executable
chmod +x structure.py distruct.py chooseK.py

# Install files
mkdir -p "${PREFIX}/bin/vars"
install -v -m 755 *.py *.so "${PREFIX}/bin"
install -v -m 755 vars/*.py vars/*.so "${PREFIX}/bin/vars"
