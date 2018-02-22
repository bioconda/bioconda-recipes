#!/bin/bash

if [ `uname` == Darwin ]
then
    export LD_LIBRARY_PATH="${PREFIX}/lib"
    #export DYLD_LIBRARY_PATH="/System/Library/Frameworks/ImageIO.framework/Versions/A/ImageIO:${PREFIX}/lib:/usr/lib:/usr/lib64"
    export STACK_ROOT="${SRC_DIR}/s"
    stack setup --extra-include-dirs ${PREFIX}/include --local-bin-path ${SRC_DIR}/s
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
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

