#!/bin/bash

set -euo

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

export LANGUAGE=en_US.UTF-8

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export CFLAGS="${CFLAGS} -m64"
fi

autoreconf -i
./configure CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--prefix="${PREFIX}" \
	--with-gmapdb="${PREFIX}/share" \
	--with-simd-level=sse42

make -j"${CPU_COUNT}"
make install
make clean

# Fix perl shebang; LC_CTYPE=C && LANG=C to fix "sed: RE error: illegal byte sequence" error on macOSX
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/dbsnp_iit
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/ensembl_genes
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/fa_coords
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gff3_genes
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gff3_introns
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gff3_splicesites
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gmap_build
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gmap_cat
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gmap_process
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_genes
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_introns
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_splicesites
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_transcript_splicesites
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gvf_iit
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/md_coords
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/psl_genes
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/psl_introns
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/psl_splicesites
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/snpindex
LC_CTYPE=C && LANG=C sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/vcf_iit
