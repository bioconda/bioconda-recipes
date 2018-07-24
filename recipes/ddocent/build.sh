#!/bin/bash

mkdir -p $PREFIX/bin

TRIM=$PREFIX/share

cp $TRIM/trimmomatic*/trim*.jar $PREFIX/bin/trimmomatic.jar
cp $TRIM/trimmomatic*/adapters/* $PREFIX/bin/

cp dDocent $PREFIX/bin/
chmod +x $PREFIX/bin/dDocent
cd scripts
chmod +x *.sh
chmod +x dDocent_filters filter_hwe_by_pop.pl
cp *.sh dDocent_filters filter_hwe_by_pop.pl $PREFIX/bin/
cd ..

