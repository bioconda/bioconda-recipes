#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]];then
  mv shasta-macOS-${PKG_VERSION} shasta
fi
if [[ "$OSTYPE" == "linux-gnu"* ]];then
  mv shasta-Linux-${PKG_VERSION} shasta
fi

chmod +x shasta
mkdir -p ${PREFIX}/bin
cp shasta ${PREFIX}/bin/shasta