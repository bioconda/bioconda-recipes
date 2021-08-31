#!/bin/bash

#Copy binery file since there is no INSTALL part in the makefile
mkdir -p ${PREFIX}/bin
chmod +x galaxy_wrappers/*/*.pl
chmod +x galaxy_wrappers/*/*.py
cp galaxy_wrappers/*/*.pl $PREFIX/bin/
cp galaxy_wrappers/*/*.py $PREFIX/bin/

