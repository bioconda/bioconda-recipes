#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

echo "PREFIX=${PREFIX}"
echo "TGT=${TGT}"

cd "${SRC_DIR}"
cp gridss-*.jar $TGT/gridss.jar
cp *.R *.sh "${TGT}"

cp $RECIPE_DIR/gridss $TGT/gridss
cp $RECIPE_DIR/gridss_r_script $TGT/gridss_r_script
cp $RECIPE_DIR/gridss_java_entrypoint $TGT/gridss_java_entrypoint

# gridss wraps gridss.sh to specify the location of the gridss jar
ln -s $TGT/gridss $PREFIX/bin
# R scripts all have a --scriptdir argument.
# gridss_r_script is a wrapper that sets this to correct location
ln -s $TGT/gridss_r_script $PREFIX/bin/gridss_somatic_filter
ln -s $TGT/gridss_r_script $PREFIX/bin/gridss_annotate_insertions_repeatmaster
# gridss_java_entrypoint is a java wrapper
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AllocateEvidence
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateInexactHomology
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateInexactHomologyBedpe
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateReferenceCoverage
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateUntemplatedSequence
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AnnotateVariants
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/AssembleBreakends
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CallVariants
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectGridssMetricsAndExtractFullReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectGridssMetricsAndExtractSVReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ComputeSamTags
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ExtractFullReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ExtractSVReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/GeneratePonBedpe
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/IdentifyVariants
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/IndexedExtractFullReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/SoftClipsToSplitReads
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectCigarMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectFragmentGCMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectGridssMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectIdsvMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectMapqMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectStructuralVariantReadMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/CollectTagMetrics
ln -s $TGT/gridss_java_entrypoint $PREFIX/bin/ReportThresholdCoverage