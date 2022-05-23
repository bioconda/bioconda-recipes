#!/bin/sh

mkdir $PREFIX/share
mkdir $PREFIX/share/orthologID

cp *.sh $PREFIX/share/orthologID
cp *pbs $PREFIX/share/orthologID
cp *txt $PREFIX/share/orthologID
cp README $PREFIX/share/orthologID
cp VERSION $PREFIX/share/orthologID
cp run_snpgenie_oid_EXAMPLE.pl $PREFIX/share/orthologID
cp -r bin $PREFIX
cp -r config $PREFIX
cp -r lib $PREFIX
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