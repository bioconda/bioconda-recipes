#!/bin/bash
# migmap runner script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # directory of current script
MIGMAP_DIR=$DIR/../share

if [[ "$@" == *'--data-dir'* ]]; then 
    java -jar $MIGMAP_DIR/migmap-0.9.7.jar "$@" # just pass command line arguments
else
    java -jar $MIGMAP_DIR/migmap-0.9.7.jar --data-dir $IGDATA "$@" # set by igblast package
fi
