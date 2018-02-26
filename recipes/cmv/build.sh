#!/bin/bash

if [ `uname` == Darwin ]
then
  export LD_LIBRARY_PATH="${PREFIX}/lib"
  export STACK_ROOT="${SRC_DIR}/s"
  export LDFLAGS="-L${PREFIX}/lib"
  export CPPFLAGS="-I${PREFIX}/include"
  echo ${PREFIX}
  echo ${SRC_DIR}/s
  mkdir ${SRC_DIR}/s
  export LOCALBIN="${SRC_DIR}/s/bin"
  mkdir $LOCALBIN
  export PATH="$LOCALBIN:$PATH"
  stack setup --stack-root ${SRC_DIR}/s --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --local-bin-path $LOCALBIN
  stack exec env --stack-root ${SRC_DIR}/s --local-bin-path $LOCALBIN
  stack path --stack-root ${SRC_DIR}/s --local-bin-path $LOCALBIN
  stack update --stack-root ${SRC_DIR}/s --local-bin-path $LOCALBIN
  stack install --stack-root ${SRC_DIR}/s --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
  #cp -p $LOCALBIN/* "${PREFIX}/bin"
  rm -r ${SRC_DIR}/s
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

