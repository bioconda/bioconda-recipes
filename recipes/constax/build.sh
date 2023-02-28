#!/bin/bash

mkdir -p $PREFIX/bin
constax=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $constax
echo "export SINTAXPATH=vsearch" > $constax/pathfile.txt
echo "export RDPPATH=classifier" >> $constax/pathfile.txt
echo "export CONSTAXPATH="$constax >> $constax/pathfile.txt

cp -r ./* $constax
sed -i'' -e 's|VERSION=2.....; BUILD=.; PREFIX=.*|VERSION="'"$PKG_VERSION"'"; BUILD="'"$PKG_BUILDNUM"'"; PREFIX="'"$PREFIX"'"|' $constax/constax_no_inputs.sh
sed -i'' -e 's|VERSION=2.....; BUILD=.; PREFIX=.*|VERSION="'"$PKG_VERSION"'"; BUILD="'"$PKG_BUILDNUM"'"; PREFIX="'"${PREFIX}"'"|' $constax/constax.sh
sed -i'' -e 's|version="2....."; build="."; prefix=".*"|version="'"$PKG_VERSION"'"; build="'"$PKG_BUILDNUM"'"; prefix="'"$PREFIX"'"|' $constax/constax_wrapper.py

chmod +x $constax/constax_no_inputs.sh
chmod +x $constax/constax.sh
chmod +x $constax/constax_wrapper.py

ln -s $constax/constax_no_inputs.sh $PREFIX/bin/constax_no_inputs.sh
ln -s $constax/constax_wrapper.py $PREFIX/bin/constax
