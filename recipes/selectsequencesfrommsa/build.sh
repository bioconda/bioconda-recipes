#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

# use the system ghc
mkdir -p ${HOME}/.stack
echo "system-ghc: true" > ${HOME}/.stack/config.yaml
ghc --version
sed -i.bak "s/lts-10.9/ghc-8.10.7/g" stack.yaml

stack setup
stack update
stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
#cleanup
rm -r .stack-work
