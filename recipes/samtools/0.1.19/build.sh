#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/include/bam"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile
rm -rf *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
	# for Mac OSX
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -Wl,-dead_strip_dylibs -headerpad_max_install_names"
fi

make CC="${CC}" \
	INCLUDES="-I. -I${PREFIX}/include -I${PREFIX}/include/ncurses" \
	LIBCURSES="-L${PREFIX}/lib -lncurses -ltinfo" \
	LIBPATH="-L${PREFIX}/lib" \
	CFLAGS="-g -Wall -O3 -I${PREFIX}/include -L${PREFIX}/lib -fPIC -Wno-deprecated-declarations" \
	-j"${CPU_COUNT}"

install -v -m 0755 samtools \
	bcftools/bcftools \
	bcftools/vcfutils.pl \
	"${PREFIX}/bin"

mv libbam.a "${PREFIX}/lib"

mv ./* ${PREFIX}/include/bam/
