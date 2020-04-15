#!/bin/bash

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX && make && make install

# support scripts
cp scripts/{beagle2chromopainter.pl,chromopainter2chromopainterv2.pl,convertrecfile.pl} $PREFIX/bin/
cp scripts/{impute2chromopainter.pl,makeuniformrecfile.pl,msms2cp.pl,phasescreen.pl} $PREFIX/bin/
cp scripts/{phasesubsample.pl,plink2chromopainter.pl} $PREFIX/bin/