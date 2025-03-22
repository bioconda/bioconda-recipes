#!/bin/sh

set -xe

# Download newer config.{sub,guess} files
wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -O config.guess
wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -O config.sub

mkdir -p ${PREFIX}/bin

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath ${PREFIX}/lib"
export CPATH=${PREFIX}/include

if [[ "$(uname)" == Darwin ]]; then
    # Fix for install_name_tool error:
    #   error: install_name_tool: changing install names or rpaths can't be
    #   redone for: ... (for architecture x86_64) because
    #   larger updated load commands do not fit (the program must be relinked,
    #   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

./configure --prefix=${PREFIX} --enable-pthreads
make
make install
