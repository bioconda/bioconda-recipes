#!/usr/bin/env bash
# ConsensusFixer wrapper script
# based on picard wrapper
set -eu -o pipefail

set -o pipefail
export LC_ALL=en_US.UTF-8

# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
# this is basically a bash re-implementation of the (GNU-only, non Mac OS X) "realpath" command
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

JAR_DIR=$DIR
ENV_PREFIX="$(dirname $(dirname $DIR))"
# if JAVA_HOME is set (non-empty), use it. Otherwise 
# Use Java installed with Anaconda to ensure correct version
java="${JAVA_HOME:-$ENV_PREFIX}/bin/java"

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts=( "-Xms512m" "-Xmx1G" )
jvm_mem_opts=()
jvm_prop_opts=()
pass_args=()
for arg in "$@"; do
    case $arg in
        '-D'*)
            jvm_prop_opts+=( "${arg}" )
            ;;
        '-XX'*)
            jvm_prop_opts+=( "${arg}" )
            ;;
         '-Xm'*)
            jvm_mem_opts+=( "${arg}" )
            ;;
         *)
            pass_args+=( "${arg}" )
            ;;
    esac
done

if (( ${#pass_args[@]} )) && [[ "${pass_args[0]}" == ch.ethz* ]]; then
    jar_arg='-cp'
else
    jar_arg='-jar'
fi
exec -a "${BASH_SOURCE[0]}" "$java" "${jvm_mem_opts[@]:-"${default_jvm_mem_opts[@]}"}" ${jvm_prop_opts[@]:+"${jvm_prop_opts[@]}"} "${jar_arg}" "$JAR_DIR/ConsensusFixer.jar" ${pass_args[@]:+"${pass_args[@]}"}

