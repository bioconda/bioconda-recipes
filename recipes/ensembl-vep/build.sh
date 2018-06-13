#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
version=92
mkdir -p $target
mkdir -p $PREFIX/bin


# Use insecure CURL
sed -i.bak 's/curl -s --location/curl -k -s --location/' INSTALL.pl
# Use vep_convert_cache.pl from vep_install.pl
sed -i.bak 's@/convert_cache.pl@/vep_convert_cache@' INSTALL.pl
# Find plugins in install directory
sed -i.bak "s@'dir_plugins=s,'@'dir_plugins=s' => (\$RealBin || []),@" vep
# Change location where INSTALL.pl looks for the zlib headers
sed -i -e "s@/usr/include/zlib.h@${PREFIX}/include@" INSTALL.pl


# Copy executables & modules
cp convert_cache.pl $target/vep_convert_cache
cp INSTALL.pl $target/vep_install
cp filter_vep $target/filter_vep
cp vep $target/vep
cp haplo $target/haplo
cp variant_recoder $target/variant_recoder
cp -r modules $target/modules

chmod 0755 $target/
ln -s $target/* $PREFIX/bin

cd $target
# Use external Bio::DB::HTS::Faidx instead of compiling interally
# Compile in VEP causes issues linking to /lib64 outside of rpath
vep_install -a a --NO_HTSLIB --NO_TEST --NO_BIOPERL --NO_UPDATE
# Remove test data
rm -rf t/

# Install plugins
curl -ks -o CADD.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/$version/CADD.pm
curl -ks -o dbNSFP.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/$version/dbNSFP.pm
curl -ks -o MaxEntScan.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/$version/MaxEntScan.pm
curl -ks -o SpliceRegion.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/$version/SpliceRegion.pm
curl -ks -o GeneSplicer.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/$version/GeneSplicer.pm
curl -ks -o dbscSNV.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/$version/dbscSNV.pm
curl -L -ks -o loftee.tar.gz https://github.com/konradjk/loftee/archive/27b0040.tar.gz
tar -xzvpf loftee.tar.gz
mv loftee-*/*.pl .
mv loftee-*/*.pm .
mv loftee-*/maxEntScan .
mv loftee-*/splice_data .
rm -f loftee.tar.gz
rm -rf loftee-*
