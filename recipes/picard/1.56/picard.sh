#!/bin/bash
# Picard executable shell script. Preserve arguments as data; never eval them.
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

# Find the installation directory, resolving relative and absolute symlinks.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
JAR_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
ENV_PREFIX="$(dirname "$(dirname "$JAR_DIR")")"
java="$ENV_PREFIX/bin/java"
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    java="$JAVA_HOME/bin/java"
fi

jvm_mem_opts=()
jvm_prop_opts=()
pass_args=()
jar_file=""
test_wrapper=false
for arg in "$@"; do
    case "$arg" in
        -D*|-XX*) jvm_prop_opts+=("$arg") ;;
        -Xm*)     jvm_mem_opts+=("$arg") ;;
        --test-wrapper) test_wrapper=true ;;
        *.jar) jar_file="$arg" ;;
        *)        pass_args+=("$arg") ;;
    esac
done

if "$test_wrapper"; then
    expected_jars=(picard-1.56.jar sam-1.56.jar  AddOrReplaceReadGroups.jar  AddOrReplaceReadGroups.jar  BamIndexStats.jar  BamToBfq.jar  BuildBamIndex.jar  CalculateHsMetrics.jar  CleanSam.jar  CollectAlignmentSummaryMetrics.jar  CollectGcBiasMetrics.jar  CollectInsertSizeMetrics.jar  CollectMultipleMetrics.jar  CollectRnaSeqMetrics.jar  CompareSAMs.jar  CreateSequenceDictionary.jar  DownsampleSam.jar  EstimateLibraryComplexity.jar  ExtractIlluminaBarcodes.jar  ExtractSequences.jar  FastqToSam.jar  FixMateInformation.jar  IlluminaBasecallsToSam.jar  IntervalListTools.jar  MarkDuplicates.jar  MeanQualityByCycle.jar  MergeBamAlignment.jar  MergeSamFiles.jar  NormalizeFasta.jar  QualityScoreDistribution.jar  ReorderSam.jar  ReplaceSamHeader.jar  RevertSam.jar  SamFormatConverter.jar  SamToFastq.jar  SortSam.jar  ValidateSamFile.jar  ViewSam.jar)
    for jar in "${expected_jars[@]}"; do
        test -e "$JAR_DIR/$jar"
    done
    exit 0
fi
if [[ -z $jar_file ]]; then
    echo 'Usage: picard <command.jar> [arguments...]' >&2
    exit 2
fi

if [[ -z ${jvm_mem_opts[0]:-} ]]; then
    jvm_mem_opts=(-Xms512m -Xmx1g)
fi

# The + form also preserves empty arrays with nounset on older Bash releases.
if [[ ${pass_args[0]:-} == org* ]]; then
    exec "$java" ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -cp "$JAR_DIR/$jar_file" ${pass_args[@]+"${pass_args[@]}"}
else
    exec "$java" ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -jar "$JAR_DIR/$jar_file" ${pass_args[@]+"${pass_args[@]}"}
fi
