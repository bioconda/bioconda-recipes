#!/bin/bash

pushd scripts/read_recruitment/
$CXX $CXXFLAGS -c edlib/src/edlib.cpp -o edlib.o -I edlib/include
$CXX $CXXFLAGS -c rr.cpp -o rr.o -I edlib/include
$CXX rr.o edlib.o -o rr -L${PREFIX}/lib -lz
rm -rf *.o Makefile r.cpp edlib kseq
popd

outdir=${PREFIX}/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${outdir}
cp -r scripts $outdir/
cp run_all.sh $outdir/
chmod +x $outdir/run_all.sh
chmod +x $outdir/scripts/*.py

mkdir -p ${PREFIX}/bin
ln -s $outdir/run_all.sh ${PREFIX}/bin/centroFlye
for f in $outdir/scripts/*.py ; do
    ln -s $f ${PREFIX}/bin
done
