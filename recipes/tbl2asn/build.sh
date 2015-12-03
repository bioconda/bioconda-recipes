#!/bin/bash

set -e -x -o pipefail


for i in $SRC_DIR/*tbl2asn.gz ; do gunzip "$i"; done
#for i in $SRC_DIR/*_tbl2asn ; do mv "$i" "${i/[a-zA-Z0-9]*.tbl2asn/tbl2asn}" ; done

cd $SRC_DIR/

binaries="\
tbl2asn \
"

mkdir -p $PREFIX/bin

for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

# if [ "$(uname)" == "Darwin" ]; then
#     echo "Platform: Mac"

#     for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

# elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
#     echo "Platform: Linux"

#     # cd to location of Makefile and source
#     cd $SRC_DIR/
#     make    

#     for i in $binaries; do cp $SRC_DIR/bmtagger/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
# fi

# chmod +x $PREFIX/bin/*