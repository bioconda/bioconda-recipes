#!/bin/bash

mkdir -p ${PREFIX}/bin/
cp -r *py ${PREFIX}/bin/
mv -v ${PREFIX}/bin/mantis.py ${PREFIX}/bin/mantis-msi2
chmod a+x ${PREFIX}/bin/mantis-msi2

cd tools
make
mv -v RepeatFinder ${PREFIX}/bin/mantis-msi2-repeat-finder
cd ..
