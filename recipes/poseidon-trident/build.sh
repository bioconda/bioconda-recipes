#!/bin/env bash

mkdir -p ~/.stack
cat << EOF > ~/.stack/config.yaml
setup-info:
  ghc:
    linux64:
        8.10.3:
            url: "https://downloads.haskell.org/~ghc/8.10.3/ghc-8.10.3-x86_64-centos7-linux.tar.xz"
            content-length: 203627484
            sha1: 19a5e446ebab64cde968bb2fc6ed97ae9c0ce3d3
            sha256: f562ca61979ff1d21e34e69e59028cb742a8eff8d84e46bbd3a750f2ac7d8ed1
EOF

stack install

mv ~/.local/bin/trident $PREFIX/bin/trident
chmod u+x $PREFIX/bin/trident
