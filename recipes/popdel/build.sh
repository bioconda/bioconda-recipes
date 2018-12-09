#!/bin/sh
make all
mkdir -p ${PREFIX}/bin
cp popdel ${PREFIX}/bin
