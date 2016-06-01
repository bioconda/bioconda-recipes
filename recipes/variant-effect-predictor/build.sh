#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# Do not install BioPerl and run tests
sed -i.bak 's/^  bioperl();/  # bioperl();/' scripts/variant_effect_predictor/INSTALL.pl
sed -i.bak 's/^  test();/  # test();/' scripts/variant_effect_predictor/INSTALL.pl
# Use curl for downloads -- works with proxies
sed -i.bak 's/our $use_curl = 0/our $use_curl = 1/' scripts/variant_effect_predictor/INSTALL.pl
# Use vep_convert_cache.pl from vep_install.pl
sed -i.bak 's@/convert_cache.pl@/vep_convert_cache.pl@' scripts/variant_effect_predictor/INSTALL.pl
# Allow convert_cache to find libraries
sed -i.bak 's@use strict;@use strict;\nuse FindBin qw($RealBin);\nuse lib $RealBin;@' scripts/variant_effect_predictor/convert_cache.pl
# Find plugins in install directory
sed -i.bak 's@$config->{dir_plugins} ||=.*@$config->{dir_plugins} ||= $RealBin;@' scripts/variant_effect_predictor/variant_effect_predictor.pl
# Change location where INSTALL.pl looks for the zlib headers
sed -i -e "s@/usr/include/zlib.h@${PREFIX}/include@" scripts/variant_effect_predictor/INSTALL.pl
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
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/fd7bd1a63afaf106ff49445127cb04451b5e63b4/CADD.pm
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/fd7bd1a63afaf106ff49445127cb04451b5e63b4/dbNSFP.pm
wget --no-check-certificate https://raw.githubusercontent.com/konradjk/loftee/537ac71a447fb21ef7e949d4f2f05a191488a9fa/LoF.pm
wget --no-check-certificate https://raw.githubusercontent.com/konradjk/loftee/537ac71a447fb21ef7e949d4f2f05a191488a9fa/splice_module.pl
