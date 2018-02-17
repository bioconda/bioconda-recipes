#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR

if [ "$(uname)" == "Darwin" ]; then
    for tool in guppy pplacer rppr; do
        for lib in \
                /usr/lib/libz.1.dylib \
                /usr/lib/libsqlite3.dylib \
                /usr/local/lib/libgsl.0.dylib \
                /usr/local/lib/libgslcblas.0.dylib
            do install_name_tool -change "${lib}" "${PREFIX}/lib/${lib##*/}" ./${tool}
        done
    done
fi

cp guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}
