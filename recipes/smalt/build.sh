#!/bin/bash
set -xef -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

rm -f config.sub
rm -f config.guess

wget https://raw.githubusercontent.com/bioconda/bioconda-recipes/70fd7ab07ad07338a840ac1b581ec94435133fd3/recipes/bambamc/config.sub
wget https://raw.githubusercontent.com/bioconda/bioconda-recipes/70fd7ab07ad07338a840ac1b581ec94435133fd3/recipes/bambamc/config.guess

autoconf
./configure --prefix="${PREFIX}" \
	--disable-option-checking --disable-dependency-tracking \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
