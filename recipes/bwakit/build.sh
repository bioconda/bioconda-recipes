#!/bin/bash

mkdir -p $PREFIX/bin

curl -L https://github.com/attractivechaos/k8/releases/download/0.2.5/k8-0.2.5.tar.bz2 |
  tar jxf - k8-0.2.5/k8-$(uname -s) && cp k8-0.2.5/k8-* $PREFIX/bin/k8

for file in *.js ; do
  { echo '#!/usr/bin/env k8'; cat "${file}"; } > "${file}.tmp"
  mv "${file}.tmp" "${file}" && chmod 0755 "${file}"
done

cp -r \
  resource-* \
  run-* \
  *.js \
  *.sh \
  $PREFIX/bin
