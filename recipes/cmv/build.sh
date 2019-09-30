#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

if [ `uname` == Darwin ]
then
    export DYLD_LIBRARY_PATH="/System/Library/Frameworks/ImageIO.framework/Resources/:${PREFIX}/lib:$DYLD_LIBRARY_PATH"
    export STACK_ROOT="${SRC_DIR}/s"
    stack setup --extra-include-dirs [${PREFIX}/include] --extra-lib-dirs [${PREFIX}/lib] --local-bin-path ${SRC_DIR}/s
    stack update
    stack install --extra-include-dirs [${PREFIX}/include] --extra-lib-dirs [${PREFIX}/lib] --local-bin-path ${PREFIX}/bin
    rm -r "${SRC_DIR}/s"
else
    stack setup --local-bin-path ${PREFIX}/bin
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin
fi

#cleanup
rm -r .stack-work

