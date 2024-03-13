#!/bin/bash
# export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LDFLAGS="-L${PREFIX}/lib"
# export CPPFLAGS="-I${PREFIX}/include"

wget https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz
tar xf ghc-9.4.7-x86_64-centos7-linux.tar.xz

echo "GHC version"
ghc-9.4.7-x86_64-unknown-linux/bin/ghc --version

WHEREAMI=$(readlink -f ghc-9.4.7-x86_64-unknown-linux/bin)

export PATH="$WHEREAMI:$PATH"

echo "WHEREAMI"
echo $WHEREAMI

echo "PATH:"
echo $PATH

echo "which ghc":
which ghc

echo "which stack": # to see where the general bin path is
which stack

# STACKROOT=/home/conda/.stack # can be evaluated with `stack path --stack-root`
# # echo "Stack Root: $STACKROOT"
# mkdir -p $STACKROOT
# touch $STACKROOT/config.yaml

# printf "setup-info:\n  ghc:\n    linux64:\n      9.4.7:\n        url: https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz\n" >> $STACKROOT/config.yaml

# cat $STACKROOT/config.yaml

stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
# # cleanup
# # rm -r .stack-work

