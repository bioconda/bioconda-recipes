#!/bin/bash
set -x

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I. -DBOOST_NO_CXX98_FUNCTION_BASE=1"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

case `uname` in
    Linux)
	DSOSUF="so"
	;;
    Darwin)
	DSOSUF="dylib"
	;;
    *)
	echo "Unknown uname '`uname`'" >&2
	exit 1
esac

# main binaries
make CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" prefix="${PREFIX}" \
	SAMLIBS="${PREFIX}/lib/libhts.${DSOSUF}" \
	SAMHEADERS="${PREFIX}/include/htslib/sam.h" \
	install -j"${CPU_COUNT}"

# EBSeq R scripts and one binary
sed -i.bak 's|#!/usr/bin/env Rscript|#!/opt/anaconda1anaconda2anaconda3/bin/Rscript|' EBSeq/rsem-*
rm -rf EBSeq/rsem-*.bak
make -C EBSeq CXX="${CXX} ${CXXFLAGS} ${LDFLAGS}" rsem-for-ebseq-calculate-clustering-info -j"${CPU_COUNT}"
install -v -m 0755 EBSeq/rsem-* "${PREFIX}/bin"

# Fix perl scripts and module
# move all perl stuff into a separate dir
mkdir -p perl-build/lib
mv ${PREFIX}/bin/rsem*.pm perl-build/lib
for n in ${PREFIX}/bin/rsem-*; do
    if head -n1 "$n" | grep -q "env perl"; then
	mv -v "$n" perl-build
    fi
done
mv rsem-control-fdr rsem-run-ebseq perl-build
cp -rf ${RECIPE_DIR}/Build.PL perl-build
cd perl-build
# now run perl install
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
