#!/bin/bash
# x-mapper executable shell script for https://github.com/mathjeff/mapper
set -e

# Find the directory of this script, including resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

JAR_DIR=$DIR
# Use the default Java installed by Conda unless JAVA_HOME is set
CONDA_DIR="$(dirname $(dirname $DIR))"
java="$CONDA_DIR/bin/java"
if [ -n "${JAVA_HOME:=}" ]; then
  if [ -e "$JAVA_HOME/bin/java" ]; then
      java="$JAVA_HOME/bin/java"
  fi
fi

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts="-Xms512m -Xmx10g"
jvm_mem_opts=""
jvm_prop_opts=""
pass_args=""
for arg in "$@"; do
    case "$arg" in
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
            # join other arguments with spaces
	    if [[ "${pass_args}" == "" ]]
            then
                pass_args="$arg"
	    else
                pass_args="$pass_args $arg"
            fi
            ;;
    esac
done

if [ "$jvm_mem_opts" == "" ]; then
    jvm_mem_opts="$default_jvm_mem_opts"
fi

# runs a command, and if it fails, outputs the failed command
function runExplain() {
  commandToRun="$1"
  shift
  if "$commandToRun" $*; then
    return
  else
    echo >&2
    echo "Failed: '$commandToRun $*'" >&2
    return 1
  fi
}

runExplain "$java" $jvm_mem_opts $jvm_prop_opts -jar "$JAR_DIR/x-mapper.jar" $pass_args
