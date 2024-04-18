#!/bin/bash -euo

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

export LC_ALL=en_US.UTF-8

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export CFLAGS="${CFLAGS} -m64"
    export LC_ALL=C
fi

case $(uname -m) in
	x86_64)
		SIMD_LEVEL="sse42"
		;;
	aarch64)
		SIMD_LEVEL="arm"
		;;
	*)
		SIMD_LEVEL="none"
		;;
esac

autoreconf -if
./configure CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--prefix="${PREFIX}" \
	--with-gmapdb="${PREFIX}/share" \
	--with-simd-level=${SIMD_LEVEL}

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
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/snpindex
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/vcf_iit

rm -rf ${PREFIX}/bin/*.bak
