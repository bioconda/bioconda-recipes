#!/bin/bash

if [ `uname` == Darwin ]
then
    export LD_LIBRARY_PATH="${PREFIX}/lib"
    export STACK_ROOT="${SRC_DIR}/s"
    export LDFLAGS="-L${PREFIX}/lib"
    export CPPFLAGS="-I${PREFIX}/include"
    echo "${PREFIX}"
    echo "${SRC_DIR}/s"
    stack setup --extra-lib-dirs "${PREFIX}/lib" --extra-include-dirs "${PREFIX}/include" --local-bin-path "${SRC_DIR}/s"
    stack install --extra-lib-dirs "${PREFIX}/lib" --extra-include-dirs "${PREFIX}/include" --local-bin-path "${PREFIX}/bin"
    rm -r "${SRC_DIR}/s"
else
  export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
  export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
  export LDFLAGS="-L${PREFIX}/lib"
  export CPPFLAGS="-I${PREFIX}/include"
  stack setup --local-bin-path ${PREFIX}/bin
  stack update
  stack install --local-bin-path ${PREFIX}/bin
fi
#cleanup
rm -r .stack-work

