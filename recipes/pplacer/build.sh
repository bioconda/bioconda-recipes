#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR

tools='guppy pplacer rppr'
if [ "$(uname)" == 'Darwin' ]; then
    # Exclude `rppr` from package due to:
    #  "install_name_tool: changing install names or rpaths can't be redone for:
    #   ./rppr (for architecture x86_64) because larger updated load commands do
    #   not fit (the program must be relinked, and you may need to use
    #   -headerpad or -headerpad_max_install_names)"
    tools='guppy pplacer'
    for tool in $tools; do
        for lib in /usr/lib/libz.1.dylib \
                   /usr/lib/libsqlite3.dylib \
                   /usr/local/lib/libgsl.0.dylib \
                   /usr/local/lib/libgslcblas.0.dylib; do
            install_name_tool -change "${lib}" "${PREFIX}/lib/${lib##*/}" ./${tool}
        done
    done
fi

cp $tools $PREFIX/bin
cd $PREFIX/bin
chmod +x $tools
