#!/bin/bash

set -efu -o pipefail

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

chmod u+x ${SRC_DIR}/configure
chmod u+x ${SRC_DIR}/build-aux/ar-lib
chmod u+x ${SRC_DIR}/build-aux/compile
chmod u+x ${SRC_DIR}/build-aux/config.guess
chmod u+x ${SRC_DIR}/build-aux/config.sub
chmod u+x ${SRC_DIR}/build-aux/depcomp
chmod u+x ${SRC_DIR}/build-aux/install-sh
chmod u+x ${SRC_DIR}/build-aux/ltmain.sh
chmod u+x ${SRC_DIR}/build-aux/missing
chmod u+x ${SRC_DIR}/build-aux/test-driver

cp README.md README

mkdir -p build
pushd build

${SRC_DIR}/configure --prefix=$PREFIX
make install

# kmc_tool may not have been built, if a C++14 compiler was not available.
# in that case, fetch the statically-compiled binary.
if [ ! -f "$PREFIX/kmc_tool" ]
then
		if [ "$(uname)" == "Darwin" ]; then
				echo "Platform: Mac"
				wget --no-check-certificate -O $PREFIX/bin/kmc_tools http://sun.aei.polsl.pl/REFRESH/kmc/downloads/2.3.0/mac/kmc_tools
				chmod u+x $PREFIX/bin/kmc_tools
		elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
				echo "Platform: Linux"
				wget --no-check-certificate -O $PREFIX/bin/kmc_tools http://sun.aei.polsl.pl/REFRESH/kmc/downloads/2.3.0/linux/kmc_tools
				chmod u+x $PREFIX/bin/kmc_tools
		fi
fi  # if kmc_tool wasn't compiled
popd
