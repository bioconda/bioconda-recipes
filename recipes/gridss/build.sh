#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

echo "PREFIX=${PREFIX}"
echo "TGT=${TGT}"

cd "${SRC_DIR}"
cp gridss-*.jar $TGT/gridss.jar
# GRIDSS tools needing argument massaging
cp gridss \
	gridss.config.R \
	gridss_annotate_vcf_kraken2 \
	gridss_annotate_vcf_repeatmasker \
	gridss_extract_overlapping_fragments \
	gridss_somatic_filter \
	libgridss.R \
	virusbreakend \
	"${TGT}/"
chmod +x ${TGT}/*
# GRIDSS tools that can be run completely as-is
cp virusbreakend-build \
	$PREFIX/bin/

# Need to go in the same directory as the jar/R files
# so we can resolve the location at runtime
cp $RECIPE_DIR/gridss_shell_with_jar_entrypoint $TGT/
cp $RECIPE_DIR/gridss_java_entrypoint $TGT/
cp $RECIPE_DIR/gridss_r_script $TGT/
chmod +x $TGT/gridss_*

rm gridsstools # don't use the pre-compiled gridsstools - rebuild it ourselves
tar zxf gridsstools-src-$PKG_VERSION.tar.gz
cd "${SRC_DIR}/gridsstools/htslib/"
autoreconf -i && ./configure && make
cd ..
autoreconf -i && ./configure && make gridsstools
cp gridsstools $PREFIX/bin

# Wrapper script to add --jar command line argument
ln -s $TGT/gridss_shell_with_jar_entrypoint $PREFIX/bin/gridss
ln -s $TGT/gridss_shell_with_jar_entrypoint $PREFIX/bin/gridss_annotate_vcf_kraken2
ln -s $TGT/gridss_shell_with_jar_entrypoint $PREFIX/bin/gridss_annotate_vcf_repeatmasker
ln -s $TGT/gridss_shell_with_jar_entrypoint $PREFIX/bin/gridss_extract_overlapping_fragments
ln -s $TGT/gridss_shell_with_jar_entrypoint $PREFIX/bin/virusbreakend

# Wrapper script to add --scriptdir command line argument
ln -s $TGT/gridss_r_script $PREFIX/bin/gridss_somatic_filter

# Wrapper script so to avoid having to run java -cp gridss.jar gridss.* ...
## gridss namespace
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AllocateEvidence
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateInexactHomology
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateInexactHomologyBedpe
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateInsertedSequence
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateReferenceCoverage
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateVariants
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AssembleBreakends
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CallVariants
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectGridssMetricsAndExtractSVReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ComputeSamTags
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ExtractFragmentsToFastq
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ExtractSVReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/GeneratePonBedpe
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/IdentifyVariants
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/InsertedSequencesToFasta
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/PrepareReference
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/PreprocessForBreakendAssembly
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/SanityCheckEvidence
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/SoftClipsToSplitReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/VirusBreakendFilter
## gridss.analysis namespace
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectCigarMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectFragmentGCMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectGridssMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectIdsvMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectMapqMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectStructuralVariantReadMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectTagMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ReportThresholdCoverage
## gridss.kraken namespace
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateVariantsKraken
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ExtractBestViralReference
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/IdentifyViralTaxa
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/SubsetToTaxonomy
## gridss.repeatmasker namespace
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateVariantsRepeatMasker
