#!/bin/bash

mkdir -p $PREFIX/bin

curl -L https://github.com/attractivechaos/k8/releases/download/0.2.5/k8-0.2.5.tar.bz2 |
  tar jxf - k8-0.2.5/k8-$(uname -s) && cp k8-0.2.5/k8-* $PREFIX/bin/k8

sed -i.bak '1i\
#!/usr/bin/env k8' *.js
chmod 0755 *.js

cp -r \
  resource-* \
  run-* \
  *.js \
  *.sh \
  $PREFIX/bin
