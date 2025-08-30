#!/bin/bash -euo

mkdir -p $PREFIX/bin
cp psirc_v1.0.pl create_custom_transcriptome_fa.pl $PREFIX/bin
ln -s $PREFIX/bin/psirc_v1.0.pl $PREFIX/bin/psirc
chmod a+x $PREFIX/bin/psirc_v1.0.pl
chmod a+x $PREFIX/bin/create_custom_transcriptome_fa.pl

# Make forked kallisto available at default location
cp forked_kallisto/Linux/kallisto $PREFIX/bin/kallisto_b
chmod a+x $PREFIX/bin/kallisto_b

# Make FAlite perl module available
cp scripts/FAlite.pm $PREFIX/lib/perl5/site_perl
chmod a+x $PREFIX/lib/perl5/site_perl/FAlite.pm

cd psirc-quant

mkdir release
cd release
cmake ..  -DCMAKE_INSTALL_PREFIX=$PREFIX
make psirc-quant
make install
