#!/bin/bash

if [ `uname` == Darwin ]
then
  export LD_LIBRARY_PATH="${PREFIX}/lib"
  mkdir -p ${SRC_DIR}/home
  export HOME=${SRC_DIR}/home
  export STACK_ROOT="$HOME/s"
  echo ${PREFIX}
  echo ${SRC_DIR}/s
  ls -l
  mkdir ${SRC_DIR}/s
  export LOCALBIN="${SRC_DIR}/s/bin"
  mkdir $LOCALBIN
  export LOCALWORK="${SRC_DIR}/s/wo"
  mkdir $LOCALWORK
  stack setup --stack-root ${SRC_DIR}/s --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --local-bin-path $LOCALBIN
  stack exec env --stack-root ${SRC_DIR}/s --local-bin-path $LOCALBIN
  stack update --stack-root ${SRC_DIR}/s --local-bin-path $LOCALBIN
  stack install --cabal-verbose --stack-root ${SRC_DIR}/s --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --local-bin-path $LOCALBIN
  cp -p $LOCALBIN/CMCV ${PREFIX}/bin
  cp -p $LOCALBIN/CMCWStoCMCV ${PREFIX}/bin
  cp -p $LOCALBIN/CMCtoHMMC ${PREFIX}/bin
  cp -p $LOCALBIN/CMV ${PREFIX}/bin
  cp -p $LOCALBIN/CMVJson ${PREFIX}/bin
  cp -p $LOCALBIN/HMMCV ${PREFIX}/bin
  cp -p $LOCALBIN/HMMCtoCMC ${PREFIX}/bin
  cp -p $LOCALBIN/HMMV ${PREFIX}/bin
  rm -r $STACK_ROOT
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

