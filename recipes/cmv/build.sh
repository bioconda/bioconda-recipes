#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
if [ `uname` == Darwin ]
then
    #export DYLD_LIBRARY_PATH="/opt/local/lib:${PREFIX}/lib:$DYLD_LIBRARY_PATH"
    export STACK_ROOT="${SRC_DIR}/s"
    stack setup --extra-include-dirs [/usr/include,${PREFIX}/include] --extra-lib-dirs [/usr/lib,${PREFIX}/lib] --local-bin-path ${SRC_DIR}/s
    stack update
    stack install --extra-include-dirs [/usr/include,${PREFIX}/include] --extra-lib-dirs [/usr/lib,${PREFIX}/lib] --local-bin-path ${PREFIX}/bin
    rm -r "${SRC_DIR}/s"
else
    stack setup
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin
fi
#cleanup
rm -r .stack-work

