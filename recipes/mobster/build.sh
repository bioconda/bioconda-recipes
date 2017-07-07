#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $PREFIX/bin

./install.sh

# install wrapper scripts
cp $RECIPE_DIR/mobster.py $outdir/mobster.py
chmod +x $outdir/mobster.py
ln -s $outdir/mobster.py $PREFIX/bin/mobster

cp $RECIPE_DIR/mobster-to-vcf.py $outdir/mobster-to-vcf.py
chmod +x $outdir/mobster-to-vcf.py
ln -s $outdir/mobster-to-vcf.py $PREFIX/bin/mobster-to-vcf

# copy jar
cp target/MobileInsertions-$PKG_VERSION.jar $outdir/

# download MobsterToVCF
cd $outdir
curl -O https://github.com/jyhehir/mobster/raw/develop/resources/MobsterVCF/MobsterVCF-0.0.1-SNAPSHOT.jar
