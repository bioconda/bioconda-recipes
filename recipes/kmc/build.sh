#!/bin/bash

set -ef -o pipefail

#export CPPFLAGS="-I${PREFIX}/include"
#export LDFLAGS="-L${PREFIX}/lib"

if [ -z "${OSX_ARCH}" ]; then
		export ARCHDIR=linux
else
		export ARCHDIR=mac
fi  

wget http://sun.aei.polsl.pl/REFRESH/kmc/downloads/2.3.0/$ARCHDIR/kmc_tools
chmod u+x kmc_tools
wget http://sun.aei.polsl.pl/REFRESH/kmc/downloads/2.3.0/$ARCHDIR/kmc_dump
chmod u+x kmc_dump
chmod u+x kmc
mv kmc kmc_tools kmc_dump $PREFIX/bin/
