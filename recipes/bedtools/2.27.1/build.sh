#!/bin/sh
mv src/utils/gzstream/version src/utils/gzstream/version.txt
make install CXX="${CXX}" prefix="${PREFIX}"
