#!/bin/bash

make
mkdir -p $PREFIX/bin
cp SmartMapPrep $PREFIX/bin
cp SmartMapRNAPrep $PREFIX/bin
cp Default/SmartMap $PREFIX/bin
