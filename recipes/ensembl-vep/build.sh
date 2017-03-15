#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
target=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin

# Do not install BioPerl and run tests
sed -i.bak 's/^  bioperl();/  # bioperl();/' INSTALL.pl
# Use insecure CURL
sed -i.bak 's/curl -s --location/curl -k -s --location/' INSTALL.pl
# Use vep_convert_cache.pl from vep_install.pl
sed -i.bak 's@/convert_cache.pl@/vep_convert_cache.pl@' INSTALL.pl
# Find plugins in install directory
sed -i.bak "s@'dir_plugins=s,'@'dir_plugins=s' => (\$RealBin || []),@" vep.pl
# Change location where INSTALL.pl looks for the zlib headers
sed -i -e "s@/usr/include/zlib.h@${PREFIX}/include@" INSTALL.pl
# Add perl shebang to vep and haplo script
sed -i "1i #!/usr/bin/env perl" vep.pl

# Copy executables & modules
cp convert_cache.pl $target/ensembl_convert_cache.pl
cp INSTALL.pl $target/ensembl_vep_install.pl
cp filter_vep.pl $target/ensembl_filter_vep.pl
cp vep.pl $target/ensembl_vep.pl
cp -r modules $target/modules

chmod 0755 $target/*.pl
ln -s $target/*.pl $PREFIX/bin

cd $target
# Use external Bio::DB::HTS::Faidx instead of compiling interally
# Compile in VEP causes issues linking to /lib64 outside of rpath
perl ensembl_vep_install.pl -a a --NO_HTSLIB --NO_TEST
# Remove test data
rm -rf t/
# Install plugins
curl -ks -o CADD.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/CADD.pm
curl -ks -o dbNSFP.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/dbNSFP.pm
curl -ks -o MaxEntScan.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/MaxEntScan.pm
curl -ks -o GeneSplicer.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/GeneSplicer.pm
curl -ks -o dbscSNV.pm https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/87/dbscSNV.pm
curl -ks -o LoF.pm https://raw.githubusercontent.com/konradjk/loftee/master/LoF.pm
curl -ks -o splice_module.pl https://raw.githubusercontent.com/konradjk/loftee/master/splice_module.pl
