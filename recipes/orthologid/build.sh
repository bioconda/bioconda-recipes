#!/bin/sh

mkdir $PREFIX/orthologID

cp *.sh $PREFIX/orthologID
cp *pbs $PREFIX/orthologID
cp *txt $PREFIX/orthologID
cp README $PREFIX/orthologID
cp readme_troubleshoot $PREFIX/orthologID
cp testdata $PREFIX/orthologID
cp VERSION $PREFIX/orthologID
cp run_snpgenie_oid_EXAMPLE.pl $PREFIX/orthologID
cp -r bin $PREFIX/orthologID
cp -r config $PREFIX/orthologID
cp -r lib $PREFIX/orthologID
cp -r phylobrowse $PREFIX/orthologID
cp -r PostProcessing $PREFIX/orthologID
cp -r testdata $PREFIX/orthologID

chmod a+x $PREFIX/orthologID/bin/orthologid.pl
chmod a+x $PREFIX/orthologID/bin/topshell.sh
chmod a+x $PREFIX/orthologID/PostProcessing/*.sh
chmod a+x $PREFIX/orthologID/PostProcessing/*.py
chmod a+x $PREFIX/orthologID/PostProcessing/*.pl
chmod a+x $PREFIX/orthologID/PostProcessing/*.R

export OID_HOME=$PREFIX/orthologID

#export OID_USER_DIR=$PREFIX/testdata/
