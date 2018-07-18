#!/bin/bash

mkdir -p $PREFIX/bin

TRIM=$PREFIX/share

cp $TRIM/trimmomatic*/trim*.jar $PREFIX/bin/trimmomatic.jar
cp $TRIM/trimmomatic*/adapters/* $PREFIX/bin/

cp dDocent $PREFIX/bin/
chmod +x $PREFIX/bin/dDocent
