#!/bin/bash

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export CFLAGS="${CFLAGS} -m64"
fi

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

autoconf
autoheader
./configure CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--prefix="${PREFIX}" \
	--with-gmapdb="${PREFIX}/share" \
	--with-simd-level=sse42

make -j"${CPU_COUNT}"
make install
make clean

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/dbsnp_iit
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/ensembl_genes
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/fa_coords
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gff3_genes
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gff3_introns
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gff3_splicesites
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gmap_build
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gmap_cat
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gmap_process
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_genes
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_introns
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_splicesites
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gtf_transcript_splicesites
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/gvf_iit
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/md_coords
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/psl_genes
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/psl_introns
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/psl_splicesites
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/vcf_iit

