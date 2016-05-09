#!/bin/bash
# Wraps ImageJ
set -o pipefail

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts="-DXms=512m -DXmx=1g"
jvm_mem_opts=""
jvm_prop_opts=""
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
         *)
            pass_args="$pass_args $arg"
            ;;
    esac
done

if [ "$jvm_mem_opts" == "" ] && [ -z ${_JAVA_OPTIONS+x} ]; then
    jvm_mem_opts="$default_jvm_mem_opts"
fi

# Detect the os.
unamestr=`uname`

if [ "$unamestr" == 'Linux' ];
then
    eval "ImageJ-linux64" $jvm_mem_opts $jvm_prop_opts --ij2 --headless --debug
elif [ "$unamestr" == 'Darwin' ];
then
    eval "ImageJ-macosx" $jvm_mem_opts $jvm_prop_opts --ij2 --headless --debug
fi
exit
