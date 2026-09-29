#!/bin/bash
# bamlist2cit launcher (bioconda wrapper).
#
# Mirrors upstream's bamlist2cit script. Calls the installed `gedi`
# command (on PATH) to drive the conversion / merge pipeline rather than
# depending on its own location, since `gedi` is exposed as a sibling
# wrapper in $PREFIX/bin.
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

p=
tmpfolder=
nthreads=6
add=

while [[ ${1-} == -* ]]; do
    case $1 in
        -h)
            printf "bamlist2cit [-p] [-t tmpfolder] [-n nthreads] xyz.bamlist\n\n"
            printf " -p\tShow progress\n"
            printf " -t\tspecify tmp folder\n"
            printf " -n\tnumber of parallel processes\n\n"
            exit 0
            ;;
        -p) p=" -p";;
        -n) shift; nthreads="$1";;
        -t) shift
            tmpfolder=" -Djava.io.tmpdir=$1"
            mkdir -p "$1"
            ;;
        -*) add="$add $1";;
    esac
    shift
done

if [ -z "${1-}" ]; then
    echo "Usage: bamlist2cit [-p] [-t tmpfolder] [-n nthreads] xyz.bamlist" >&2
    exit 2
fi

proc=0
PIDS=
CITS=
for i in $(grep -v "^#" "$1"); do
    echo "Converting $i"
    gedi ${tmpfolder}${add} -e Bam2CIT "${i}.cit" "${i}" &
    PIDS="$PIDS $!"
    CITS="$CITS ${i}.cit"
    proc=$((proc + 1))
    if [ "${proc}" -eq "${nthreads}" ]; then
        wait $PIDS
        PIDS=
        proc=0
    fi
done
wait $PIDS

proc=0
PIDS=
for i in $(grep -v "^#" "$1"); do
    echo "Correcting ${i}.cit"
    gedi ${tmpfolder}${add} -e CorrectCIT "${i}.cit" &
    PIDS="$PIDS $!"
    proc=$((proc + 1))
    if [ "${proc}" -eq "${nthreads}" ]; then
        wait $PIDS
        PIDS=
        proc=0
    fi
done
wait $PIDS

echo "Merging"
gedi ${tmpfolder}${add} -e MergeCIT ${p} -c "$1.cit" ${CITS}
gedi ${tmpfolder}${add} -e ReadCount ${p} "$1.cit"
