#!/bin/bash
set -eu

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

make -C squid-1.5.11 CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

mv sort-snos sort-snos.pl

## Build Perl

mkdir perl-build
#mv sort-snos perl-build
find . -name '*.pl' ! -path './perl-build/*.pl' -exec mv {} perl-build \;
# find . -name "*.pm`" | xargs -I {} cp {} perl-build/lib
cd perl-build

cp -f ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..
## End build perl

ln -sf $PREFIX/bin/sort-snos.pl $PREFIX/bin/sort-snos

install -v -m 0755 snoscan snoscan[AHY] $PREFIX/bin

chmod +rx $PREFIX/bin/genpept2gsi.pl
chmod +rx $PREFIX/bin/sort-snos.pl
chmod +rx $PREFIX/bin/genbank2gsi.pl
chmod +rx $PREFIX/bin/swiss2gsi.pl
chmod +rx $PREFIX/bin/fasta2gsi.pl
chmod +rx $PREFIX/bin/pir2gsi.pl
