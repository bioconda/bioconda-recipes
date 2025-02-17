#!/usr/bin/env bash

# copying over all necessary files
mkdir -p $PREFIX/bin/
chmod a+x bin/metafx
cp bin/metafx $PREFIX/bin/
cp -r bin/metafx-modules $PREFIX/bin/
cp -r bin/metafx-scripts $PREFIX/bin/

cp $PREFIX/bin/metafx-modules/* $PREFIX/bin/
cp $PREFIX/bin/metafx-scripts/* $PREFIX/bin/
