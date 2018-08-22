#!/bin/bash
set -eu -o pipefail

declare -a PROGRAMS=(
    'BAMTagHistogram'
    'BAMTagofTagCounts'
    'BaseDistributionAtReadPosition'
    'CollapseBarcodesInPlace'
    'CollapseTagWithContext'
    'ConvertToRefFlat'
    'CreateIntervalsFiles'
    'DetectBeadSynthesisErrors'
    'DigitalExpression'
    'FilterBAM'
    'FilterBAMByTag'
    'GatherGeneGCLength'
    'GatherMolecularBarcodeDistributionByGene'
    'GatherReadQualityMetrics'
    'PolyATrimmer'
    'ReduceGTF'
    'SelectCellsByNumTranscripts'
    'SingleCellRnaSeqMetricsCollector'
    'TagBamWithReadSequenceExtended'
    'TagReadWithGeneExon'
    'TagReadWithInterval'
    'TrimStartingSequence'
    'ValidateReference'
)

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
bindir=$PREFIX/bin
mkdir -p $bindir
cp -r ./* $outdir/

for PROG in "${PROGRAMS[@]}"
do
	sed -i'.bak' -E 's@^thisdir=.+@thisdir='$outdir'@g' "${outdir}/${PROG}"
	rm -f "${outdir}/${PROG}.bak"
	ln -s "${outdir}/${PROG}" "${bindir}/${PROG}"
	chmod 0755 "${bindir}/${PROG}"
done

