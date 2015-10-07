#!/bin/bash

mkdir -p $PREFIX/bin

if [ $PY3K -eq 1 ]
then
    2to3 --write cuffmerge
fi

cp cufflinks $PREFIX/bin
cp cuffcompare $PREFIX/bin
cp cuffdiff $PREFIX/bin
cp cuffmerge $PREFIX/bin
cp gffread $PREFIX/bin
cp gtf_to_sam $PREFIX/bin
cp cuffnorm $PREFIX/bin
cp cuffquant $PREFIX/bin
