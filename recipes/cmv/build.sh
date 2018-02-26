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
  export LOCALWORK="${SRC_DIR}/s/work"
  mkdir $LOCALWORK
  stack setup --stack-root ${SRC_DIR}/s --work-dir $LOCALWORK --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --local-bin-path $LOCALBIN
  stack exec env --stack-root ${SRC_DIR}/s --work-dir $LOCALWORK --local-bin-path $LOCALBIN
  stack update --stack-root ${SRC_DIR}/s --work-dir $LOCALWORK --local-bin-path $LOCALBIN
  stack install --stack-root ${SRC_DIR}/s --work-dir $LOCALWORK --extra-lib-dirs ${PREFIX}/lib --extra-include-dirs ${PREFIX}/include --local-bin-path $LOCALBIN
  cp -p $LOCALBIN/CMCV ${PREFIX}/bin
  cp -p $LOCALBIN/CMCWStoCMCV ${PREFIX}/bin
  cp -p $LOCALBIN/CMCtoHMMC ${PREFIX}/bin
  cp -p $LOCALBIN/CMV ${PREFIX}/bin
  cp -p $LOCALBIN/CMVJson ${PREFIX}/bin
  cp -p $LOCALBIN/HMMCV ${PREFIX}/bin
  cp -p $LOCALBIN/HMMCtoCMC ${PREFIX}/bin
  cp -p $LOCALBIN/HMMV ${PREFIX}/bin
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

