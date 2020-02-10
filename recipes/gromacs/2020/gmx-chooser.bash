#!/bin/bash

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

DIR="$( dirname "$SOURCE" )"
FLAGS=`cat /proc/cpuinfo | grep ^flags | head -1`
if echo $FLAGS | grep " avx512f " > /dev/null && test -d ${DIR}/../bin.AVX_512 && echo `${DIR}/../bin.AVX_512/identifyavx512fmaunits` | grep "2" > /dev/null; then
    ARCH="AVX_512"
elif echo $FLAGS | grep " avx2 " > /dev/null && test -d ${DIR}/../bin.AVX2_256; then
    ARCH="AVX2_256"
elif echo $FLAGS | grep " avx " > /dev/null && test -d ${DIR}/../bin.AVX_256; then
    ARCH="AVX_256"
else
    ARCH="SSE2"
fi
${DIR}/../bin.${ARCH}/gmx $@
