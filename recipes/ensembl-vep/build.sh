#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
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
cp -r modules $target/modules

chmod 0755 $target/
ln -s $target/* $PREFIX/bin

cd $target
# Use external Bio::DB::HTS::Faidx instead of compiling interally
# Compile in VEP causes issues linking to /lib64 outside of rpath
vep_install -a a --NO_HTSLIB --NO_TEST --NO_BIOPERL
# Remove test data
rm -rf t/

# Install plugins
curl -ks -o CADD.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/88/CADD.pm
curl -ks -o dbNSFP.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/88/dbNSFP.pm
curl -ks -o MaxEntScan.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/88/MaxEntScan.pm
curl -ks -o GeneSplicer.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/88/GeneSplicer.pm
curl -ks -o dbscSNV.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/88/dbscSNV.pm
curl -ks -o LoF.pm https://raw.githubusercontent.com/konradjk/loftee/master/LoF.pm
curl -ks -o splice_module.pl https://raw.githubusercontent.com/konradjk/loftee/master/splice_module.pl
