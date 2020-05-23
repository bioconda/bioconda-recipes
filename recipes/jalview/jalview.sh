#!/usr/bin/env bash

###############################
# Wrapper for Jalview
#
# Note, in order to run commandline-only calls use 
#   -nodisplay
#
# By default, this wrapper executes java -version to determine the JRE version
# Set JALVIEW_JRE=j1.8 or JALVIEW_JRE=j11 to skip the version check 
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
if [[ "$JALVIEW_JRE" != "j11" && "$JALVIEW_JRE" != "j1.8" ]]; then
  JALVIEW_JRE="j11"
  # if java 8 is installed we pick the j1.8 build
  if [[ $( java -version 2>&1 | grep '"1.8' ) != "" ]]; then JALVIEW_JRE=j1.8; fi
fi

java -jar $DIR/jalview-all-${JALVIEW_JRE}.jar ${@};
