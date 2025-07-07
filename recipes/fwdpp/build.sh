#!/bin/bash

CPPFLAGS="-I$PREFIX/include $CPPFLAGS" LDFLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib $LDFLAGS" ./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"

cd testsuite
# For time reasons, 
# skip compiling & 
# executing long-running
# tests:
TESTS="unit/fwdpp_unit_tests unit/sugar_unit_tests unit/extensions_unit_tests integration/extensions_integration_tests"

make ${TESTS} -j"${CPU_COUNT}"

for i in $TESTS
do
    ./$i
done

cd ..
make install
