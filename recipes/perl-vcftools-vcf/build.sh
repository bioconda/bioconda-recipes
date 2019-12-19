#!/bin/bash
set -eu
mkdir -p perl-lib/lib
cp src/perl/*.pm perl-lib/lib
cp src/perl/fill-* src/perl/tab-to-vcf src/perl/vcf-* perl-lib
# Fix naming scheme of package to make Builder happy
sed -i.bak 's/Vcf.pm.  Module/Vcf - Module/' perl-lib/lib/Vcf.pm
cp $RECIPE_DIR/Build.PL perl-lib
cd perl-lib
perl Build.PL
perl ./Build
perl ./Build test 
perl ./Build install --installdirs site

chmod u+rwx $PREFIX/bin/*
