#!/usr/bin/env bash

###############################
# Wrapper for Jalview
#
# Note, in order to run commandline-only calls use 
#   -nodisplay
#
###############################

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"; # get final path of this script

# set install path of jalview
JALVIEWDIR=$DIR; 

CLASSPATH=`echo $JALVIEWDIR/*.jar | sed -e 's/r /r:/g'`

# total physical memory in mb

MAXMEM=`python -c 'from psutil import virtual_memory;print ("-Xmx%iM" % (256 if (virtual_memory().total/(1024*1024)) < 1024 else ((virtual_memory().total/(1024*1024))-1024)))'`

if [[ $( $( which conda || echo $CONDA_EXE ) list openjdk | egrep -e 'openjdk:\W+9' ) ]]; then JAVA9MOD="--add-modules=java.se.ee --illegal-access=warn"; fi;

java $MAXMEM $JAVA9MOD -classpath $CLASSPATH jalview.bin.Jalview ${@};
