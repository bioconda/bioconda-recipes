#!/bin/bash
set -x
mkdir -p ${PREFIX}/bin

pushd KMC
make CC=$CXX
popd

pushd PgSA
for f in nbproject/*.mk ; do
sed -i.bak "s#gcc#${CC}#g" $f
done

make build CONF=pgsalib CCC=$CXX CXX=$CXX
make build CONF=pgsagen CCC=$CXX CXX=$CXX
popd

make CC=$CXX

# copy binaries
cp bin/* ${PREFIX}/bin
cp HG-CoLoR ${PREFIX}/bin
