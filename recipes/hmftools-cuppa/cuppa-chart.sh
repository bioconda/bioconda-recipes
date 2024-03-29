#!/bin/bash
# hmftools CUPPA chart executable shell script
# https://github.com/hartwigmedical/hmftools/tree/master/cuppa
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

ENV_PREFIX="$(dirname $(dirname $DIR))"
# Use Python installed with Anaconda to ensure correct version
python="$ENV_PREFIX/bin/python"

# Run with argument passthrough
eval ${python} ${DIR}/chart/cuppa-chart.py ${@}
