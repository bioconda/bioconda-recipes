#!/bin/bash
# exomiser-rest-prioritiser executable shell script, adapted from VarScan shell script
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

java=java

if [ -z "${JAVA_HOME:=}" ]; then
  if [ -e "$JAVA_HOME/bin/java" ]; then
      java="$JAVA_HOME/bin/java"
  fi
fi

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts="-Xms512m -Xmx1g"
jvm_mem_opts=""
jvm_prop_opts=""
pass_args=""
for arg in "$@"; do
    case $arg in
        '-D'*)
            jvm_prop_opts="$jvm_prop_opts '$arg'"
            ;;
        '-XX'*)
            jvm_prop_opts="$jvm_prop_opts '$arg'"
            ;;
         '-Xm'*)
            jvm_mem_opts="$jvm_mem_opts '$arg'"
            ;;
         *)
            pass_args="$pass_args '$arg'"
            ;;
    esac
done

if [ "$jvm_mem_opts" == "" ]; then
    jvm_mem_opts="$default_jvm_mem_opts"
fi

pass_arr=($pass_args)
if [[ "$1" == self-test ]]
then
    error=0
    java -version &>/dev/null
    if [[ $0 -ne 0 ]]; then
        >&2 echo "ERROR: Call to 'java -version' failed."
        error=1
    fi
    if [[ ! -e $JAR_DIR/exomiser-rest-prioritiser-$PKG_VERSION.jar ]]; then
        >&2 echo "ERROR: JAR file not found at $JAR_DIR/exomiser-rest-prioritiser-$PKG_VERSION.jar "
        error=1
    fi
    if [[ $error -ne 0 ]]; then
        >&2 echo "ERROR: failed self-test, see above for details"
        exit 1
    fi
elif [[ ${pass_arr[0]:=} == \'org* ]]
then
    eval "$java" $jvm_mem_opts $jvm_prop_opts -cp "$JAR_DIR/exomiser-rest-prioritiser-$PKG_VERSION.jar" $pass_args
else
    eval "$java" $jvm_mem_opts $jvm_prop_opts -jar "$JAR_DIR/exomiser-rest-prioritiser-$PKG_VERSION.jar" $pass_args
fi
exit
