#!/bin/bash

mkdir -p $PREFIX/bin

pushd bwakit-0.7.15
cp -r resource-* $PREFIX/bin
popd

pushd bwa-0.7.17/bwakit
for file in *.js ; do
  { echo '#!/usr/bin/env k8'; cat "${file}"; } > "${file}.tmp"
  mv "${file}.tmp" "${file}" && chmod 0755 "${file}"
done
cp -r \
  run-* \
  *.js \
  *.sh \
  $PREFIX/bin
popd
