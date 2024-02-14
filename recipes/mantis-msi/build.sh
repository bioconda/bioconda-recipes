#!/bin/bash

mkdir -p ${PREFIX}/bin/
cp -r *py ${PREFIX}/bin/
mv -v ${PREFIX}/bin/mantis.py ${PREFIX}/bin/mantis-msi.py
chmod a+x ${PREFIX}/bin/mantis-msi.py

cd tools
make
mv RepeatFinder ${PREFIX}/bin/RepeatFinder
cd ..
