#!/bin/bash
# export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64"
# export LDFLAGS="-L${PREFIX}/lib"
# export CPPFLAGS="-I${PREFIX}/include"

wget https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz
tar xvf ghc-9.4.7-x86_64-centos7-linux.tar.xz
export PATH="$PATH:~/ghc-9.4.7-x86_64-unknown-linux/bin"

stack install --local-bin-path ${PREFIX}/bin --system-ghc
# cleanup
# rm -r .stack-work

