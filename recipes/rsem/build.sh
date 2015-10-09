#! /bin/bash
pushd $SRC_DIR

binaries="\
rsem-build-read-index \
rsem-synthesis-reference-transcripts \
rsem-tbam2gbam \
rsem-parse-alignments \
rsem-simulate-reads \
rsem-calculate-credibility-intervals \
rsem-scan-for-paired-end-reads \
rsem-sam-validator \
rsem-bam2wig \
rsem-run-em \
rsem-get-unique \
rsem-extract-reference-transcripts \
rsem-bam2readdepth \
rsem-preref \
rsem-run-gibbs \
rsem_perl_utils.pm \
EBSeq/rsem-for-ebseq-calculate-clustering-info \
EBSeq/rsem-for-ebseq-find-DE \
EBSeq/rsem-for-ebseq-generate-ngvector-from-clustering-info \
"
WHAT_IS_NEW="WHAT_IS_NEW"

INSTALLDIR=$PREFIX/lib/rsem
BINDIR=$PREFIX/bin
mkdir -p $BINDIR
mkdir -p $INSTALLDIR

make
make ebseq

for i in $binaries; do cp $i $INSTALLDIR && chmod +x $INSTALLDIR/$(basename $i); done
cp $WHAT_IS_NEW $INSTALLDIR;
for i in $binaries; do
    echo "#! /bin/bash" > $BINDIR/$(basename $i);
    echo 'DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >>  $BINDIR/$(basename $i);
    echo '$DIR/../lib/rsem/'$(basename $i) >> $BINDIR/$(basename $i);
    chmod +x $BINDIR/$(basename $i);
done
