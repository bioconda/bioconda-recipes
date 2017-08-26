#!/bin/sh

#downloading outside of meta.yaml because bioconda lint cannot handle multiple list till they more to verison 3 of bioconda

curl -L -s https://github.com/phac-nml/snvphyl-tools/archive/conda-dev4.tar.gz > archive.tar.gz
tar -zxvf archive.tar.gz

#copy over custom bcftools plugin
cp snvphyl*/bcfplugins/filter_snv_density.c plugins/

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd htslib*
./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make
cd ..

./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make prefix=$PREFIX CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS
make prefix=$PREFIX CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS plugins install
