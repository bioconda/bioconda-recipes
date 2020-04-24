#!/bin/bash
# GenomeSTRiP executable shell script
# (adapted from recipes/picard/picard.sh contributed by Brad Chapman, Daniel Klevebring, Christian Brueffer, Brad Langhorst)
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

usage () {
  echo "usage: genomestrip [java_options] <subcommand> [<subcommand args>]"
  echo ""
  echo "Possible subcommands include:"
  echo ""
  echo "Pipelines (Queue Scripts)"
  echo "  SVPreprocess"
  echo "  SVDiscovery"
  echo "  SVGenotyper"
  echo "  CNVDiscoveryPipeline"
  echo "  LCNVDiscoveryPipeline"
  echo ""
  echo "Variant Annotation"
  echo "  SVAnnotator"
  echo ""
  echo "Utilities"
  echo "  GenerateHaploidCNVGenotypes"
  echo "  PlotGenotypingResults"
  echo "  GenerateDepthProfiles"
  exit 0
}

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

export SV_DIR=$DIR
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
default_jvm_mem_opts="-Xms512m -Xmx4g"
jvm_mem_opts=""
jvm_prop_opts=""
subcommand=""
pass_args=()
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
    *)
      if [[ $subcommand == '' ]] ; then 
        subcommand="$arg"
      else
        pass_args+=("${arg}")
      fi
    esac
done

if [[ $subcommand == '' ]] ; then
  usage
fi

class=''
qscript=''
case $subcommand in
  'SVPreprocess') 
    class='org.broadinstitute.gatk.queue.QCommandLine'
    qscript="${SV_DIR}/qscript/SVPreprocess.q"
   ;;
  'SVDiscovery') 
    class='org.broadinstitute.gatk.queue.QCommandLine'
    qscript="${SV_DIR}/qscript/SVDiscovery.q"
   ;;
  'SVGenotyper') 
    class='org.broadinstitute.gatk.queue.QCommandLine'
    qscript="${SV_DIR}/qscript/SVGenotyper.q"
   ;;
  'CNVDiscoveryPipeline') 
    class='org.broadinstitute.gatk.queue.QCommandLine'
    qscript="${SV_DIR}/qscript/discovery/cnv/CNVDiscoveryPipeline.q"
   ;;
  'LCNVDiscoveryPipeline') 
    class='org.broadinstitute.gatk.queue.QCommandLine'
    qscript="${SV_DIR}/qscript/discovery/lcnv/LCNVDiscoveryPipeline.q"
   ;;
  'SVAnnotator')
    class='org.broadinstitute.sv.main.SVAnnotator'
   ;;
  'GenerateHaploidCNVGenotypes')
    class='org.broadinstitute.sv.apps.GenerateHaploidCNVGenotypes'
   ;;
  'PlotGenotypingResults')
    class='org.broadinstitute.sv.apps.PlotGenotypingResults'
   ;;
  'GenerateDepthProfiles')
    class='org.broadinstitute.gatk.queue.QCommandLine'
    qscript="${SV_DIR}/qscript/profiles/GenerateDepthProfiles.q"
   ;;
esac

if [[ $class == '' ]] ; then
  usage
fi

if [ "$jvm_mem_opts" == "" ]; then
    jvm_mem_opts="$default_jvm_mem_opts"
fi

classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"     
if [ "$qscript" == "" ]; then
  $java $jvm_mem_opts $jvm_prop_opts -cp ${classpath} ${class} ${pass_args[*]}
else
  $java $jvm_mem_opts $jvm_prop_opts -cp ${classpath} ${class} \
     -S ${qscript} \
     -S ${SV_DIR}/qscript/SVQScript.q \
     -cp ${classpath} \
     -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
     -configFile ${SV_DIR}/conf/genstrip_parameters.txt \
     -run \
     ${pass_args[*]}
fi

exit 0

