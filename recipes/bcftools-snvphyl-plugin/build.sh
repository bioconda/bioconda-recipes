#!/bin/sh

#downloading outside of meta.yaml because bioconda lint cannot handle multiple list till they move to version 3 of bioconda

curl -L -s https://github.com/phac-nml/snvphyl-tools/archive/1.8.1.tar.gz > 1.8.1.tar.gz
tar -zxvf 1.8.1.tar.gz

#copy over custom bcftools plugin
cp snvphyl*/bcfplugins/filter_snv_density.c plugins/

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

./configure --prefix=$PREFIX --enable-libcurl
make
mkdir -p $PREFIX/libexec/bcftools
mv plugins/filter_snv_density.so $PREFIX/libexec/bcftools/
