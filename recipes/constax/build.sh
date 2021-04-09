#!/bin/bash

mkdir -p $PREFIX/bin
constax=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $constax
echo "export SINTAXPATH=vsearch" > $constax/pathfile.txt
echo "export RDPPATH=classifier" >> $constax/pathfile.txt
echo "export CONSTAXPATH="$constax >> $constax/pathfile.txt

cp -r ./* $constax
sed -i'' -e "s/VERSION=2....; BUILD=.; BUILD_STRING=.*/VERSION=$PKG_VERSION; BUILD=$PKG_BUILDNUM; BUILD_STRING=$PKG_BUILD_STRING/" $constax/constax_no_inputs.sh
sed -i'' -e "s/VERSION=2....; BUILD=.; BUILD_STRING=.*/VERSION=$PKG_VERSION; BUILD=$PKG_BUILDNUM; BUILD_STRING=$PKG_BUILD_STRING/" $constax/constax.sh
sed -i'' -e 's/version="2...."; build="."; build_string=".*"/version="'"$PKG_VERSION"'"; build="'"$PKG_BUILDNUM"'"; build_string="'"$PKG_BUILD_STRING"'"/' $constax/constax_wrapper.py

chmod +x $constax/constax_no_inputs.sh
chmod +x $constax/constax.sh
chmod +x $constax/constax_wrapper.py


mkdir -p $PREFIX/bin
ln -s $constax/constax_no_inputs.sh $PREFIX/bin/constax_no_inputs.sh
ln -s $constax/constax_wrapper.py $PREFIX/bin/constax
