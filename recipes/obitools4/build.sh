#!/bin bash

set -eo

# The author provides the binaries and the source code in the tarball
# There is a protection mechanism in GO that prevents re-builds. Disable it
go env -w GOFLAGS=-buildvcs=false


if [ "$(uname)" == "Darwin" ]; then
    make "CGO_CFLAGS=$CGO_CFLAGS -I$CONDA_PREFIX/include"
else
    make "CGO_CFLAGS=$CGO_CFLAGS -I$CONDA_PREFIX/include -L$CONDA_PREFIX/lib" 
fi


mkdir -p "$PREFIX/bin"

tools=(
    obiannotate
    obiclean
    obicleandb
    obicomplement
    obiconsensus
    obiconvert
    obicount
    obicsv
    obidemerge
    obidistribute
    obigrep
    obijoin
    obik
    obikmermatch
    obikmersimcount
    obilandmark
    obimatrix
    obimicrosat
    obimultiplex
    obipairing
    obipcr
    obireffamidx
    obirefidx
    obiscript
    obisplit
    obisummary
    obitag
    obitagpcr
    obitaxonomy
    obiuniq 
)

for tool in "${tools[@]}" ; do

    cp build/$tool ${PREFIX}/bin/$tool

done
