#!/bin/bash

mkdir -p $PREFIX/bin

./configure --prefix=$PREFIX && make && make install

# if [[ $(uname -s) == Darwin ]]; then
# 	cp fs_mac $PREFIX/bin/fs
# else
# 	cp fs_linux_glibc2.3 $PREFIX/bin/fs
# fi

# # support scripts
# cp {beagle2chromopainter.pl,chromopainter2chromopainterv2.pl,convertrecfile.pl} $PREFIX/bin/
# cp {impute2chromopainter.pl,makeuniformrecfile.pl,msms2cp.pl,phasescreen.pl} $PREFIX/bin/
# cp {phasesubsample.pl,plink2chromopainter.pl} $PREFIX/bin/