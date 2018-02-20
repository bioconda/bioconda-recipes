#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
if [ `uname` == Darwin ]
then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
    export STACK_ROOT="${SRC_DIR}/s"
    stack setup --local-bin-path ${SRC_DIR}/s
    stack update
    stack install --local-bin-path ${PREFIX}/bin
    rm -r "${SRC_DIR}/s"
else
  stack setup --local-bin-path ${PREFIX}/bin
  stack update
  stack install --local-bin-path ${PREFIX}/bin
fi
#cleanup
rm -r .stack-work

