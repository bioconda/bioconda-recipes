#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
# on mac, add conda lib to @rpath
if [ "$(uname)" == "Darwin" ]; then
    cp PCAone ${PREFIX}/bin
    # install_name_tool -add_rpath ${PREFIX}/lib ${PREFIX}/bin/PCAone
else 
# Set up build environment
    export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
    export C_INCLUDE_PATH="${PREFIX}/include:${C_INCLUDE_PATH}"
    export CPLUS_INCLUDE_PATH="${PREFIX}/include:${CPLUS_INCLUDE_PATH}"
    export CFLAGS="$CFLAGS -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
    awk -v dir=${PREFIX} 'NR==7 {$0="MKLROOT="dir}; NR==41 {$0="LPATHS=-L"dir"/lib"}; 1' Makefile > linux.makefile && make -f linux.makefile && cp PCAone ${PREFIX}/bin
fi

# put runtime lib into user's env
# [ -f $HOME/.bashrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.bashrc
# [ -f $HOME/.zshrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.zshrc

