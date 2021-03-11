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
# By default, this wrapper does NOT restrict the memory consumption of Jalview.
# Set eg. JALVIEW_MAXMEM=1g to set the maximal memory of Jalview's VM
#
###############################

# ARG1 saved to check whether we need "-open" later
ARG1=$1

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

# check if memory maximum is set and if so forward to java-based jalview call
if [ -z "$JALVIEW_MAXMEM" ]; then
  VMMAXMEM=""
else
  VMMAXMEM="-Xmx${JALVIEW_MAXMEM}"
fi

# check to see if $1 is set and is not start of other cli set args
OPEN=""
if [ -n "$ARG1" -a "$ARG1" = "${ARG1#-}" ]; then
 # first argument exists and does not start with a "-"
 OPEN="-open"
fi

java $VMMAXMEM -jar $DIR/jalview-all-${JALVIEW_JRE}.jar $OPEN ${@};
