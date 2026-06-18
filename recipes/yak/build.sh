#!/bin/bash -ex

mkdir -p ${PREFIX}/bin

#install_name_tool error fix
if [[ "$(uname)" == Darwin ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -headerpad_max_install_names"
fi

make INCLUDES="-I${PREFIX}/include" CFLAGS="${CFLAGS} -g -Wall -O3 -L${PREFIX}/lib"
cp -rf yak ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/yak
