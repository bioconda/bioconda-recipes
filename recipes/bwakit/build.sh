#!/bin/bash

mkdir -p $PREFIX/bin

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
