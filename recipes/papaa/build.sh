#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p ${PREFIX}/share/papaa
cp -r * ${PREFIX}/share/papaa
ln -s ${PREFIX}/share/papaa/python/scripts/*.py ${PREFIX}/bin/
ln -s ${PREFIX}/share/papaa/r/scripts/*.R ${PREFIX}/bin/

chmod +x ${PREFIX}/share/papaa/python/scripts/*.py
chmod +x ${PREFIX}/share/papaa/r/scripts/*.R
