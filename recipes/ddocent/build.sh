#!/bin/bash

mkdir -p $PREFIX/bin

#bash install_dDocent_requirements $PREFIX/bin

TRIM=$(readlink -f trimmomatic | sed 's/trimmomatic//' )

cp $TRIM/trimmomatic.jar $PREFIX/bin/trimmomatic.jar
cp $TRIM/adapters/* $PREFIX/bin/

cp dDocent $PREFIX/bin/
chmod +x $PREFIX/bin/dDocent
