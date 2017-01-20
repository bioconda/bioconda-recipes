#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin/

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

    cp $SRC_DIR/bin/* $PREFIX/bin/

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cd $SRC_DIR/c++/
    ./configure --prefix=$PREFIX

    make -j${CPU_COUNT}

    cp $SRC_DIR/c++/ReleaseMT/bin/* $PREFIX/bin/
fi

# patch perl shebang line
sed -i 's/ \/usr\/bin\/perl -w/\/usr\/bin\/env perl/' $PREFIX/bin/legacy_blast.pl $PREFIX/bin/update_blastdb.pl

chmod +x $PREFIX/bin/*
