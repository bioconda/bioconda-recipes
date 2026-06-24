#!/usr/bin/env bash

# get the directory of this script, as per https://stackoverflow.com/a/246128
SCRIPT_DIR=$(cd -- "$( dirname -- $(realpath "${BASH_SOURCE[0]}") )" &> /dev/null && pwd)

java -jar "$SCRIPT_DIR"/AlienTrimmer.jar "$@"
