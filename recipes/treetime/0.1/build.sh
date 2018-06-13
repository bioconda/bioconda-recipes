#!/bin/bash

BINARY_HOME=$PREFIX/bin
PKG_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PREFIX/bin
mkdir -p $PKG_HOME

# copy source to bin
cp -R $SRC_DIR/* $PKG_HOME/

binaries="\
ancestral_reconstruction.py \
timetree_inference.py \
"


for i in $binaries; do 
    cd $PKG_HOME
    # add a hashbang line to the main two executable python files
    echo "#!/usr/bin/env python" > "$i.mod" && cat "$i" >> "$i.mod"

    # replace the original python files with the modified ones
    mv "$i.mod" "$i"
    chmod +x "$i"
    cd $BINARY_HOME

    # create symlinks from bin/ to each of the executable files
    ln -s "$PKG_HOME/$i" "$i"
done