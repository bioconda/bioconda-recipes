#!/bin/bash

  curl -SL https://github.com/subrata-codeons/mapinsights/archive/refs/tags/v${PKG_VERSION}.tar.gz -o mapinsights-latest.tar.gz
  tar -xzf mapinsights-latest.tar.gz
  cd mapinsights-${PKG_VERSION}
  echo "${PKG_VERSION}"
  echo "I am in desire path : $PWD"
  ls bgzf.c
  gcc --version
  make
 
  mkdir -p "${PREFIX}/bin"
  cp mapinsights "${PREFIX}/bin/"
