#!/bin/bash

mkdir -p $PREFIX/bin
constax=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $constax
echo "export SINTAXPATH=vsearch" > $constax/pathfile.txt
echo "export RDPPATH=classifier" >> $constax/pathfile.txt
echo "export CONSTAXPATH="$constax >> $constax/pathfile.txt

cp -r ./* $constax
sed -i "s/VERSION=2....; BUILD=./VERSION=$PKG_VERSION; BUILD=$PKG_BUILDNUM/" $constax/constax_no_inputs.sh
sed -i "s/VERSION=2....; BUILD=./VERSION=$PKG_VERSION; BUILD=$PKG_BUILDNUM/" $constax/constax.sh
sed -i 's/version="2...."; build="."/version="'"$PKG_VERSION"'"; build="'"$PKG_BUILDNUM"'"/' $constax/constax_wrapper.py

chmod +x $constax/constax_no_inputs.sh
chmod +x $constax/constax.sh
chmod +x $constax/constax_wrapper.py


mkdir -p $PREFIX/bin
ln -s $constax/constax_no_inputs.sh $PREFIX/bin/constax_no_inputs.sh
ln -s $constax/constax_wrapper.py $PREFIX/bin/constax
