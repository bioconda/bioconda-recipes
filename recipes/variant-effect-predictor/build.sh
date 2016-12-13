#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# Do not install BioPerl and run tests
sed -i.bak 's/^  bioperl();/  # bioperl();/' scripts/variant_effect_predictor/INSTALL.pl
sed -i.bak 's/^  test();/  # test();/' scripts/variant_effect_predictor/INSTALL.pl
# Use insecure CURL
sed -i.bak 's/curl --location/curl -k --location/' scripts/variant_effect_predictor/INSTALL.pl
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
# Use external Bio::DB::HTS::Faidx instead of compiling interally
# Compile in VEP causes issues linking to /lib64 outside of rpath
perl vep_install.pl -a a --NO_HTSLIB --CURL
# Remove test data
rm -rf t/
# Install plugins
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/CADD.pm
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/dbNSFP.pm
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/MaxEntScan.pm
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/GeneSplicer.pm
wget --no-check-certificate https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/dbscSNV.pm
wget --no-check-certificate https://raw.githubusercontent.com/konradjk/loftee/master/LoF.pm
wget --no-check-certificate https://raw.githubusercontent.com/konradjk/loftee/master/splice_module.pl
