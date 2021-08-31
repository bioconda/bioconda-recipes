#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -vp * "${TGT}"

cp $RECIPE_DIR/pisces.sh $TGT/pisces
ln -s $TGT/pisces $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pisces"

# Get recalibration; can use multiple source downloads
# when move to conda-build 3
VERSION=5.2.10.49
wget --no-check-certificate https://github.com/Illumina/Pisces/releases/download/v$VERSION/VariantQualityRecalibration_$VERSION.tar.gz
tar -xzvpf VariantQualityRecalibration*.tar.gz
rm VariantQualityRecalibration*.tar.gz
mkdir -p $TGT/pisces_vqr
mv VariantQualityRecalibration*/* $TGT/pisces_vqr
cp $RECIPE_DIR/pisces_vqr.sh $TGT/pisces_vqr/pisces_vqr
ln -s $TGT/pisces_vqr/pisces_vqr $PREFIX/bin
chmod 0755 "${PREFIX}/bin/pisces_vqr"
