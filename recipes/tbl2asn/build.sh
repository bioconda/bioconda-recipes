#!/bin/bash

set -e -x -o pipefail

DESTDIR=$PREFIX/opt/tbl2asn-$PKG_VERSION

cd $SRC_DIR/

for i in $SRC_DIR/*tbl2asn.gz ; do gunzip "$i"; done
#for i in $SRC_DIR/*_tbl2asn ; do mv "$i" "${i/[a-zA-Z0-9]*.tbl2asn/tbl2asn}" ; done

binaries="\
*.tbl2asn \
"

mkdir -p $DESTDIR
for i in $binaries; do chmod +x $SRC_DIR/$i && cp $SRC_DIR/$i $DESTDIR/${i/*.tbl2asn/tbl2asn} && ln -s $DESTDIR/tbl2asn $PREFIX/bin/tbl2asn ; done

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