#!/bin/bash
set -x
mkdir -p $PREFIX/bin
mv * $PREFIX/bin
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
export TERM=xterm
echo "running setup.sh"

# Execute the new installer.
sh ${PREFIX}/bin/install.sh

# clean up
rm -rf $PREFIX/bin/src $PREFIX/bin/*.log $PREFIX/bin/*.go $PREFIX/bin/*.yaml $PREFIX/bin/*.sh
