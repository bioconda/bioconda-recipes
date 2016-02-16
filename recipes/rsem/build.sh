#! /bin/bash
pushd $SRC_DIR

binaries="\
EBSeq/rsem-for-ebseq-find-DE \
EBSeq/rsem-for-ebseq-generate-ngvector-from-clustering-info \
convert-sam-for-rsem \
rsem-bam2readdepth \
rsem-bam2wig \
rsem-build-read-index \
rsem-calculate-credibility-intervals \
rsem-calculate-expression \
rsem-control-fdr \
rsem-extract-reference-transcripts \
rsem-gen-transcript-plots \
rsem-generate-data-matrix \
rsem-generate-ngvector \
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
rsem_perl_utils.pm \
"

INSTALLDIR=$PREFIX/lib/rsem
BINDIR=$PREFIX/bin
mkdir -p $BINDIR
mkdir -p $INSTALLDIR

make
make ebseq

for i in $binaries; do cp $i $INSTALLDIR && chmod +x $INSTALLDIR/$(basename $i); done
for i in $binaries; do
    echo "#! /bin/bash" > $BINDIR/$(basename $i);
    echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $BINDIR/$(basename $i);
    echo '$DIR/../lib/rsem/'$(basename $i) '$@' >> $BINDIR/$(basename $i);
    chmod +x $BINDIR/$(basename $i);
done
