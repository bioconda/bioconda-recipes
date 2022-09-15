#!/bin/bash

if command -v gcc-ar &> /dev/null; then
  export AR=gcc-ar
elif command -v llvm-ar &> /dev/null; then
  export AR=llvm-ar
fi

./compile

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/include/
mkdir -p ${PREFIX}/lib/

cp -r install/bin/* ${PREFIX}/bin/
cp -r install/include/* ${PREFIX}/include/
cp -r install/lib/* ${PREFIX}/lib/

# python wrappers:
$PYTHON -m pip install install/lib/btllib/python
