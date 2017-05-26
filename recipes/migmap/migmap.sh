#!/bin/bash

# migmap runner script

# directory of current script, from http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

MIGMAP_DIR=$SCRIPT_DIR/../share

# calls igblastn internally, which itself export IGDATA temporarily
# for some reason migmap expects the internal_data and optional_file directories to be in $MIGMAP_DIR/data, 
# so temporarily symlink this
ln -s $MIGMAP_DIR/igblast $MIGMAP_DIR/data
java -jar $MIGMAP_DIR/migmap-0.9.7.jar "$@"
rm -f $MIGMAP_DIR/data