#!/bin/bash -ex

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

#install_name_tool error fix
if [[ "$(uname)" == Darwin ]]; then
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

make INCLUDES="-I${PREFIX}/include" CFLAGS="${CFLAGS} -g -Wall -O2 -L${PREFIX}/lib"
cp -rf yak ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/yak
