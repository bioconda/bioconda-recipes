#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
if [ `uname` == Darwin ]
then
    export STACK_ROOT="${SRC_DIR}/s"
    stack setup --extra-include-dirs ${PREFIX}/include --extra-lib-dirs [${PREFIX}/lib,/usr/local/opt/libiconv/lib,/usr/local/lib,/usr/lib] --local-bin-path ${SRC_DIR}/s
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin
    rm -r "${SRC_DIR}/s"
else
    stack setup
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin
fi
#cleanup
rm -r .stack-work

