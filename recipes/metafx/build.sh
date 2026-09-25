#!/usr/bin/env bash

set -xe

# copying over all necessary files
mkdir -p $PREFIX/bin/
install -v -m 0755 bin/metafx $PREFIX/bin/
cp -r bin/metafx-modules $PREFIX/bin/
cp -r bin/metafx-scripts $PREFIX/bin/

ln -s $PREFIX/bin/metafx-modules/* $PREFIX/bin/
ln -s $PREFIX/bin/metafx-scripts/* $PREFIX/bin/
