#!/bin/bash
# hmftools gene-utils executable shell script
# https://github.com/hartwigmedical/hmftools/tree/master/gene-utils
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

JAR_DIR=$DIR
ENV_PREFIX="$(dirname "$(dirname "$DIR")")"
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
default_jvm_mem_opts=(-Xms512m -Xmx1g)
jvm_mem_opts=()
jvm_prop_opts=()
pass_args=()
for arg in "$@"; do
    case $arg in
        '-D'*)
            jvm_prop_opts+=("$arg")
            ;;
        '-XX'*)
            jvm_prop_opts+=("$arg")
            ;;
         '-Xm'*)
            jvm_mem_opts+=("$arg")
            ;;
         *)
	    pass_args+=("$arg")
            ;;
    esac
done

if [ ${#jvm_mem_opts[@]} -eq 0 ]; then
    jvm_mem_opts=("${default_jvm_mem_opts[@]}")
fi

if [[ ${pass_args[0]:-} == com.hartwig.* ]]
then
    exec "$java" ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -cp "$JAR_DIR/gene-utils.jar" ${pass_args[@]+"${pass_args[@]}"}

else
    exec "$java" ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -jar "$JAR_DIR/gene-utils.jar" ${pass_args[@]+"${pass_args[@]}"}

fi
