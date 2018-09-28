#!/bin/sh
chmod +x makeMakefile.sh
./makeMakefile.sh
make
mkdir ${PREFIX}/ogdf
mkdir ${PREFIX}/ogdf/lib
mkdir ${PREFIX}/ogdf/include
cp _release/libOGDF.a ${PREFIX}/ogdf/lib/
cp -R ogdf ${PREFIX}/ogdf/include/
