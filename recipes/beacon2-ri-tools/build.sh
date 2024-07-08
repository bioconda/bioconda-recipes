#!/bin/bash

set -exo pipefail

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export BEACON_SOURCE_DIR=$PREFIX/opt/BEACON" > $PREFIX/etc/conda/activate.d/beacon2-ri-tools-sourcedir.sh
chmod a+x $PREFIX/etc/conda/activate.d/beacon2-ri-tools-sourcedir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset BEACON_SOURCE_DIR" > $PREFIX/etc/conda/deactivate.d/beacon2-ri-tools-sourcedir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/beacon2-ri-tools-sourcedir.sh



cd $SRC_DIR

mkdir -p $PREFIX/lib/perl5/site_perl/BEACON
cp -R BEACON/Help.pm $PREFIX/lib/perl5/site_perl/BEACON
cp -R BEACON/Config.pm $PREFIX/lib/perl5/site_perl/BEACON
cp -R BEACON/Beacon.pm $PREFIX/lib/perl5/site_perl/BEACON
cp -R BEACON/bin/BFF.pm $PREFIX/lib/perl5/site_perl
cp -R BEACON/bin/*.sh $PREFIX/lib/perl5/site_perl
cp -R utils/bff_api/bff-api $PREFIX/lib/perl5/site_perl
cp -R utils/bff_queue/bff-queue $PREFIX/lib/perl5/site_perl
cp -R utils/bff_queue/minion_ui.pl $PREFIX/lib/perl5/site_perl
cp -R utils/models2xlsx/parse_defaultSchema.pl $PREFIX/lib/perl5/site_perl


chmod a+x $PREFIX/lib/perl5/site_perl/BEACON/*
chmod a+x $PREFIX/lib/perl5/site_perl/BFF.pm
chmod a+x $PREFIX/lib/perl5/site_perl/*.sh
chmod a+x $PREFIX/lib/perl5/site_perl/*.pl
chmod a+x $PREFIX/lib/perl5/site_perl/bff-*

sed -i.bak 's|../src/perl5|../opt/beacon2-ri-tools/src/perl5|g' $PREFIX/lib/perl5/site_perl/BEACON/*
sed -i.bak 's|../src/perl5|../opt/beacon2-ri-tools/src/perl5|g' $PREFIX/lib/perl5/site_perl/BFF.pm
sed -i.bak 's|../src/perl5|../opt/beacon2-ri-tools/src/perl5|g' $PREFIX/lib/perl5/site_perl/*.pl
sed -i.bak 's|../src/perl5|../opt/beacon2-ri-tools/src/perl5|g' $PREFIX/lib/perl5/site_perl/bff-*
sed -i.bak 's|../src/perl5|../opt/beacon2-ri-tools/src/perl5|g' $PREFIX/lib/perl5/site_perl/*.sh

rm $PREFIX/lib/perl5/site_perl/BEACON/*.bak
rm $PREFIX/lib/perl5/site_perl/*.bak

BINARY_HOME=$PREFIX/bin

cp -R beacon $BINARY_HOME/
cp -R utils/pxf2bff/pxf2bff  $BINARY_HOME/
cp -R utils/bff_validator/bff-validator  $BINARY_HOME/
cp -R utils/models2xlsx/csv2xlsx $BINARY_HOME/
cp -R BEACON/bin/*.pl $BINARY_HOME/
chmod a+x $BINARY_HOME/beacon
chmod a+x $BINARY_HOME/pxf2bff
chmod a+x $BINARY_HOME/bff-validator
chmod a+x $BINARY_HOME/csv2xlsx
chmod a+x $BINARY_HOME/*.pl

# export PATH=$PREFIX/bin:${PATH}


sed -i.bak 's|../src/perl5|../opt/beacon2-ri-tools/src/perl5|g' $PREFIX/bin/*
rm $PREFIX/bin/*.bak
mkdir -p $PREFIX/opt/beacon2-ri-tools/
cp -r * $PREFIX/opt/beacon2-ri-tools/
