#!/bin/bash
cd v$PKG_VERSION
mkdir -p ${PREFIX}/bin
mv *.py ${PREFIX}/bin/
mv *.sh ${PREFIX}/bin/
