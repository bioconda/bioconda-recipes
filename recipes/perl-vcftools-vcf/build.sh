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

chmod +rx $PREFIX/bin/vcf-compare
chmod +rx $PREFIX/bin/fill-an-ac
chmod +rx $PREFIX/bin/vcf-to-tab
chmod +rx $PREFIX/bin/fill-aa
chmod +rx $PREFIX/bin/vcf-convert
chmod +rx $PREFIX/bin/vcf-fix-newlines
chmod +rx $PREFIX/bin/vcf-merge
chmod +rx $PREFIX/bin/fill-ref-md5
chmod +rx $PREFIX/bin/vcf-indel-stats
chmod +rx $PREFIX/bin/vcf-fix-ploidy
chmod +rx $PREFIX/bin/vcf-isec
chmod +rx $PREFIX/bin/vcf-stats
chmod +rx $PREFIX/bin/vcf-subset
chmod +rx $PREFIX/bin/vcf-phased-join
chmod +rx $PREFIX/bin/vcf-query
chmod +rx $PREFIX/bin/vcf-consensus
chmod +rx $PREFIX/bin/vcf-shuffle-cols
chmod +rx $PREFIX/bin/vcf-validator
chmod +rx $PREFIX/bin/vcf-contrast
chmod +rx $PREFIX/bin/vcf-haplotypes
chmod +rx $PREFIX/bin/vcf-tstv
chmod +rx $PREFIX/bin/vcf-sort
chmod +rx $PREFIX/bin/vcf-concat
chmod +rx $PREFIX/bin/vcf-annotate
chmod +rx $PREFIX/bin/tab-to-vcf
chmod +rx $PREFIX/bin/fill-fs
