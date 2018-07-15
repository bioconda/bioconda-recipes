#!/bin/bash

mkdir -p $PREFIX/bin

#bash install_dDocent_requirements $PREFIX/bin

TRIM=$PREFIX/share

ls -a $TRIM/trimmomatic*

cp $TRIM/trimmomatic*/trim*.jar $PREFIX/bin/trimmomatic.jar
cp $TRIM/trimmomatic*adapters/* $PREFIX/bin/

cp dDocent $PREFIX/bin/
chmod +x $PREFIX/bin/dDocent
