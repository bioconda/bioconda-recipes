#!/usr/bin/bash
set -x

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
make \
    CXX=$CXX \
    CXXFLAGS="$CXXFLAGS" \
    CPPFLAGS="$CPPFLAGS -I$PREFIX/include -I." \
    SAMLIBS=$PREFIX/lib/libhts.$DSOSUF \
    SAMHEADERS=$PREFIX/include/htslib/sam.h \
    LDFLAGS="$LDFLAGS -L$PREFIX/lib" \
    prefix="$PREFIX" \
    install

# EBSeq R scripts and one binary
sed -i.bak 's|#!/usr/bin/env Rscript|#!'$(which Rscript)'|' EBSeq/rsem-*
rm EBSeq/rsem-*.bak
make -C EBSeq CXX="$CXX $CXXFLAGS $LDFLAGS" rsem-for-ebseq-calculate-clustering-info
cp EBSeq/rsem-* $PREFIX/bin

# Fix perl scripts and module
# move all perl stuff into a separate dir
mkdir -p perl-build/lib
mv $PREFIX/bin/rsem*.pm perl-build/lib
for n in $PREFIX/bin/rsem-*; do
    if head -n1 "$n" | grep -q "env perl"; then
	mv -v "$n" perl-build
    fi
done
mv rsem-control-fdr rsem-run-ebseq perl-build
cp ${RECIPE_DIR}/Build.PL perl-build
cd perl-build
# now run perl install
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
