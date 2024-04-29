#!/bin/bash

which make
which perl
echo
echo ======
ls -RF
echo "PERL5LIB: $PERL5LIB"
echo ======
echo
perl Makefile.PL
make
make install

mkdir -p  ${PREFIX}/bin 
mkdir -pv ${PREFIX}/lib/perl5
cp -v SneakerNet.plugins/*.pl ${PREFIX}/bin/
cp -v SneakerNet.plugins/*.py ${PREFIX}/bin/
cp -v SneakerNet.plugins/*.sh ${PREFIX}/bin/
cp -v scripts/*.pl            ${PREFIX}/bin/
cp -v lib/perl5/SneakerNet.pm ${PREFIX}/lib/perl5

# Need to keep the conf.bak and copy it to 
# the working copy conf.
cp -r config.bak ${PREFIX}/config.bak
cp -r config.bak ${PREFIX}/config
chmod 775 ${PREFIX}/bin/*
export PERL5LIB=$PERL5LIB:${PREFIX}/lib/perl5

echo
echo ======
echo "new PERL5LIB: $PERL5LIB"
perl -MData::Dumper -e 'print Dumper \@INC;'
echo ======
echo

