#!/bin/bash
# Picard executable shell script
set -eu -o pipefail

set -o pipefail
export LC_ALL=en_US.UTF-8

# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

JAR_DIR=$DIR
ENV_PREFIX="$(dirname $(dirname $DIR))"
# Use Java installed with Anaconda to ensure correct version
java="$ENV_PREFIX/bin/java"

# if JAVA_HOME is set (non-empty), use it. Otherwise keep "java"
if [ -n "${JAVA_HOME:=}" ]; then
  if [ -e "$JAVA_HOME/bin/java" ]; then
      java="$JAVA_HOME/bin/java"
  fi
fi

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts="-Xms512m -Xmx1g"
test=false
jvm_mem_opts=""
jvm_prop_opts=""
jar_file=""
pass_args=""
for arg in "$@"; do
    case $arg in
        '-D'*)
            jvm_prop_opts="$jvm_prop_opts $arg"
            ;;
        '-XX'*)
            jvm_prop_opts="$jvm_prop_opts $arg"
            ;;
        '-Xm'*)
            jvm_mem_opts="$jvm_mem_opts $arg"
            ;;
        '--test-wrapper')
            test=true
            ;;
        *'.jar')
            jar_file="$arg"
            ;;
        *)
            pass_args="$pass_args $arg"
            ;;
    esac
done

if $test; then
    EXPECTED_JARS=(picard-1.56.jar sam-1.56.jar  AddOrReplaceReadGroups.jar  AddOrReplaceReadGroups.jar  BamIndexStats.jar  BamToBfq.jar  BuildBamIndex.jar  CalculateHsMetrics.jar  CleanSam.jar  CollectAlignmentSummaryMetrics.jar  CollectGcBiasMetrics.jar  CollectInsertSizeMetrics.jar  CollectMultipleMetrics.jar  CollectRnaSeqMetrics.jar  CompareSAMs.jar  CreateSequenceDictionary.jar  DownsampleSam.jar  EstimateLibraryComplexity.jar  ExtractIlluminaBarcodes.jar  ExtractSequences.jar  FastqToSam.jar  FixMateInformation.jar  IlluminaBasecallsToSam.jar  IntervalListTools.jar  MarkDuplicates.jar  MeanQualityByCycle.jar  MergeBamAlignment.jar  MergeSamFiles.jar  NormalizeFasta.jar  QualityScoreDistribution.jar  ReorderSam.jar  ReplaceSamHeader.jar  RevertSam.jar  SamFormatConverter.jar  SamToFastq.jar  SortSam.jar  ValidateSamFile.jar  ViewSam.jar)
    for jar in ${EXPECTED_JARS[@]}; do
        echo "Checking if $JAR_DIR/$jar can be found"
        test -e $JAR_DIR/$jar || exit 1
    done
    exit 0
fi

if [ "$jvm_mem_opts" == "" ]; then
    jvm_mem_opts="$default_jvm_mem_opts"
fi

pass_arr=($pass_args)
if [[ ${pass_arr[0]:=} == org* ]]
then
    eval "$java" $jvm_mem_opts $jvm_prop_opts -cp "$JAR_DIR/$jar_file" $pass_args
else
    eval "$java" $jvm_mem_opts $jvm_prop_opts -jar "$JAR_DIR/$jar_file" $pass_args
fi
exit
