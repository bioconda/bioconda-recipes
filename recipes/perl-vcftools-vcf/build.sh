#!/bin/bash
set -eu

mkdir -p perl-lib/lib

wget https://raw.githubusercontent.com/vcftools/vcftools/refs/heads/master/src/perl/tab-to-vcf -O src/perl/tab-to-vcf
wget https://raw.githubusercontent.com/vcftools/vcftools/refs/heads/master/src/perl/vcf-haplotypes -O src/perl/vcf-haplotypes

cp -f src/perl/*.pm perl-lib/lib
cp -f src/perl/fill-* perl-lib
cp -f src/perl/vcf-* perl-lib
cp -f src/perl/tab-to-vcf perl-lib
# Fix naming scheme of package to make Builder happy
sed -i.bak 's/Vcf.pm.  Module/Vcf - Module/' perl-lib/lib/Vcf.pm
rm -rf perl-lib/lib/*.bak
cp -f "${RECIPE_DIR}/Build.PL" perl-lib

cd perl-lib

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site

chmod 0755 ${PREFIX}/bin/fill-*
chmod 0755 ${PREFIX}/bin/vcf-*
chmod 0755 ${PREFIX}/bin/tab-to-vcf
