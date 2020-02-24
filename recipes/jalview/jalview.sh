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

# decide which jalview jar to launch - either 'j11' or 'j1.8'
J_VERSION="j11"

# if java 8 is installed we pick the j1.8 build
if [[ $( conda list openjdk | egrep -e 'openjdk\W+8' ) ]]; then J_VERSION=j1.8; fi

java -jar $DIR/jalview-all-${J_VERSION}.jar ${@};
