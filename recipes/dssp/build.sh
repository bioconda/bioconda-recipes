#!/bin/bash

set -e

# Link dynamically
sed -i -e 's/\-static //' makefile

echo "DEST_DIR=${PREFIX}" > make.config
echo "MAN_DIR=${PREFIX}/share/man/man1" >> make.config

echo "BOOST_INC_DIR=${BUILD_PREFIX}/include" >> make.config
echo "BOOST_LIB_DIR=${BUILD_PREFIX}/lib" >> make.config
# Use conda-provided cxx
sed -i -e 's/^CXX/#CXX/' makefile

# clang++ won't find std::tuple unless in C++11 mode;
# don't compile with anything newer than C++11 since we use the removed
# std::unary_function
if [ `uname -s` = "Darwin" ]; then
  CFLAGS="-std=c++11 -Wno-enum-constexpr-conversion ${CFLAGS}"
fi

make -j${CPU_COUNT} install
