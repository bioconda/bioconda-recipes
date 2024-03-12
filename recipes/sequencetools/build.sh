#!/bin/bash
# export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LDFLAGS="-L${PREFIX}/lib"
# export CPPFLAGS="-I${PREFIX}/include"

# wget https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz
# tar xf ghc-9.4.7-x86_64-centos7-linux.tar.xz
# export PATH="$PATH:$PWD/ghc-9.4.7-x86_64-unknown-linux/bin"


STACKROOT=/home/conda/.stack # can be evaluated with `stack path --stack-root`
# echo "Stack Root: $STACKROOT"
mkdir -p $STACKROOT
touch $STACKROOT/config.yaml

printf "setup-info:\n  ghc:\n    linux64:\n      9.4.7:\n        url: https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz\n" >> $STACKROOT/config.yaml

cat $STACKROOT/config.yaml

stack install --local-bin-path ${PREFIX}/bin
# cleanup
# rm -r .stack-work

