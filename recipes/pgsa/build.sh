#!/bin/bash
for f in nbproject/*.mk ; do
    sed -i.bak "s#gcc#$CC#g;s#g++#$CXX#g" $f
done

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include/pseudogenome/
mkdir -p ${PREFIX}/include/readsset/
mkdir -p ${PREFIX}/include/sais/
mkdir -p ${PREFIX}/include/suffixarray/
mkdir -p ${PREFIX}/include/test/
mkdir -p ${PREFIX}/include/index/

# build binaries and lib
make build CONF=pgsagen
make build CONF=pgsatest
make build CONF=pgsalib

# copy .so into lib
cp dist/pgsalib/*/libPgSA.so ${PREFIX}/lib

# copy executables into bin
cp dist/pgsagen/*/PgSAgen ${PREFIX}/bin
cp dist/pgsatest/*/PgSAtest ${PREFIX}/bin

# copy .h into include
cp src/*.h ${PREFIX}/include/
cp src/pseudogenome/*.h ${PREFIX}/include/pseudogenome/
cp src/readsset/*.h ${PREFIX}/include/readsset/
cp src/sais/*.h ${PREFIX}/include/sais/
cp src/suffixarray/*.h ${PREFIX}/include/suffixarray/
cp src/test/*.h ${PREFIX}/include/test/
cp src/index/*.h ${PREFIX}/include/index/
