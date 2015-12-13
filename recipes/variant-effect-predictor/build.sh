#!/bin/bash
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# Do not install BioPerl and run tests
sed -i.bak 's/^  bioperl();/  # bioperl();/' scripts/variant_effect_predictor/INSTALL.pl
sed -i.bak 's/^  test();/  # test();/' scripts/variant_effect_predictor/INSTALL.pl
# Use curl for downloads -- works with proxies
sed -i.bak 's/our $use_curl = 0/our $use_curl = 1/' scripts/variant_effect_predictor/INSTALL.pl
# Allow convert_cache to find libraries
sed -i.bak 's@use strict;@use strict;\nuse FindBin qw($RealBin);\nuse lib $RealBin;@' scripts/variant_effect_predictor/convert_cache.pl
# Find plugins in install directory
sed -i.bak 's@$config->{dir_plugins} ||=.*@$config->{dir_plugins} ||= $RealBin;@' scripts/variant_effect_predictor/variant_effect_predictor.pl
cp scripts/variant_effect_predictor/convert_cache.pl $target/vep_convert_cache.pl
cp scripts/variant_effect_predictor/INSTALL.pl $target/vep_install.pl
cp scripts/variant_effect_predictor/variant_effect_predictor.pl $target
cp scripts/variant_effect_predictor/filter_vep.pl $target
chmod 0755 $target/*.pl
ln -s $target/*.pl $PREFIX/bin

cd $target
perl vep_install.pl -a a
# Remove test data
rm -rf t/
# Install plugins
wget --no-check-certificate https://raw.githubusercontent.com/ensembl-variation/VEP_plugins/master/CADD.pm
wget --no-check-certificate https://raw.githubusercontent.com/ensembl-variation/VEP_plugins/master/dbNSFP.pm
wget --no-check-certificate https://raw.githubusercontent.com/konradjk/loftee/master/LoF.pm
