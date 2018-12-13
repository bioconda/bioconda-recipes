#!/usr/bin/env bash

set -x -e

pushd $SRC_DIR

binaries="\
convert-sam-for-rsem \
EBSeq/rsem-for-ebseq-calculate-clustering-info \
EBSeq/rsem-for-ebseq-find-DE \
EBSeq/rsem-for-ebseq-generate-ngvector-from-clustering-info \
extract-transcript-to-gene-map-from-trinity \
rsem-bam2readdepth \
rsem-bam2wig \
rsem-build-read-index \
rsem-calculate-credibility-intervals \
rsem-calculate-expression \
rsem-control-fdr \
rsem-extract-reference-transcripts \
rsem-generate-data-matrix \
rsem-generate-ngvector \
rsem-gen-transcript-plots \
rsem-get-unique \
rsem-gff3-to-gtf \
rsem-parse-alignments \
rsem-plot-model \
rsem-plot-transcript-wiggles \
rsem-prepare-reference \
rsem-preref \
rsem-refseq-extract-primary-assembly \
rsem-run-ebseq \
rsem-run-em \
rsem-run-gibbs \
rsem-sam-validator \
rsem-scan-for-paired-end-reads \
rsem-simulate-reads \
rsem-synthesis-reference-transcripts \
rsem-tbam2gbam \
"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I${PREFIX}/include"

########################################################
### Prepare Samtools/Htslib
########################################################

sed -i.bak 's/^CPPFLAGS =$//g' samtools-1.3/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' samtools-1.3/Makefile

sed -i.bak 's/^CPPFLAGS =$//g' samtools-1.3/htslib-1.3/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' samtools-1.3/htslib-1.3/Makefile

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' samtools-1.3/Makefile

# Remove rdynamic which can cause build issues on OSX
# https://sourceforge.net/p/samtools/mailman/message/34699333/
sed -i.bak 's/ -rdynamic//g' samtools-1.3/Makefile
sed -i.bak 's/ -rdynamic//g' samtools-1.3/htslib-1.3/configure

########################################################
### Build rsem
########################################################

INSTALLDIR=$PREFIX/lib/rsem
BINDIR=$PREFIX/bin
mkdir -p $BINDIR
mkdir -p $INSTALLDIR

make
make ebseq

for i in $binaries; do cp $i $INSTALLDIR && chmod +x $INSTALLDIR/$(basename $i); done
for i in $binaries; do
    echo "#!/usr/bin/env bash" > $BINDIR/$(basename $i);
    echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $BINDIR/$(basename $i);
    echo '$DIR/../lib/rsem/'$(basename $i) '$@' >> $BINDIR/$(basename $i);
    chmod +x $BINDIR/$(basename $i);
done

########################################################
### Do Perl Things
########################################################


mkdir -p perl-build/lib
#mv *pl perl-build
mv *.pm perl-build/lib
mv rsem-calculate-expression perl-build
mv rsem-control-fdr perl-build
mv rsem-generate-data-matrix perl-build
mv rsem-plot-transcript-wiggles perl-build
mv rsem-prepare-reference perl-build
mv rsem-run-ebseq perl-build
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

perl ./Build.PL

# patch shebang line to make it shorter
perl -i.bak -wpe 's[^#!.+][#!/usr/bin/env perl]' Build

./Build manifest
./Build install --installdirs site

chmod u+rwx $PREFIX/bin/*
