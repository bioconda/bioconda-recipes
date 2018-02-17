#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR

if [ "$(uname)" == "Darwin" ]; then
    # ugly workaround for:
    #  "install_name_tool: changing install names or rpaths can't be redone for:
    #   ./rppr (for architecture x86_64) because larger updated load commands do
    #   not fit (the program must be relinked, and you may need to use
    #   -headerpad or -headerpad_max_install_names)"
    gslcblas_src=lib/libgslcblas.0.dylib
    gslcblas_dst=gslcblas.0.dylib
    ln -s "${PREFIX}/{gslcblas_src}" "${PREFIX}/{gslcblas_dst}"

    for tool in guppy pplacer rppr; do
        for lib in /usr/lib/libz.1.dylib \
                   /usr/lib/libsqlite3.dylib \
                   /usr/local/lib/libgsl.0.dylib
            do install_name_tool -change "${lib}" "${PREFIX}/lib/${lib##*/}" ./${tool}
        done
        install_name_tool -change "/usr/local/${gslcblas_src}" "${PREFIX}/${gslcblas_dst}" ./${tool}
    done
fi

cp guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}
