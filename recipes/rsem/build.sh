#! /bin/bash
pushd $SRC_DIR

mkdir -p $PREFIX/bin

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
WHAT_IS_NEW \
EBSeq/rsem-for-ebseq-calculate-clustering-info \
EBSeq/rsem-for-ebseq-find-DE \
EBSeq/rsem-for-ebseq-generate-ngvector-from-clustering-info \
"

make
make ebseq

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$(basename $i); done
