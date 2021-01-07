#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]];then
  mv ${PKG_NAME}-macOS-${PKG_VERSION} shasta
fi
if [[ "$OSTYPE" == "linux-gnu"* ]];then
  mv ${PKG_NAME}-Linux-${PKG_VERSION} shasta
fi

chmod +x shasta
mkdir -p ${PREFIX}/bin
cp shasta ${PREFIX}/bin/shasta
