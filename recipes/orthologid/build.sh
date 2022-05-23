#!/bin/sh

mkdir $PREFIX/share/orthologID

cp *.sh $PREFIX/share/orthologID
cp *pbs $PREFIX/share/orthologID
cp *txt $PREFIX/share/orthologID
cp README $PREFIX/share/orthologID
cp VERSION $PREFIX/share/orthologID
cp run_snpgenie_oid_EXAMPLE.pl $PREFIX/share/orthologID
cp -r bin $PREFIX/bin
cp -r config $PREFIX/config
cp -r lib $PREFIX/lib
cp -r PostProcessing $PREFIX/share/orthologID
cp -r testdata $PREFIX/share/orthologID

chmod a+x $PREFIX/bin/orthologid.pl
chmod a+x $PREFIX/bin/topshell.sh
chmod a+x $PREFIX/share/orthologID/PostProcessing/*.sh
chmod a+x $PREFIX/share/orthologID/PostProcessing/*.py
chmod a+x $PREFIX/share/orthologID/PostProcessing/*.pl
chmod a+x $PREFIX/share/orthologID/PostProcessing/*.R

export OID_HOME="${PREFIX}/orthologID"
export OID_USER_DIR="${PREFIX}/orthologID/testdata/"