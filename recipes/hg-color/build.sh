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

# fix paths in HG-CoLoR script that expect another level of bin/ subdirectory
# also the botched up path to PsAGen; everything is in the same bin directory
sed -i -e 's#^\$hgf[^ ]\+/\([^ ]\+\)#$hgf/\1#' ${PREFIX}/bin/HG-CoLoR
