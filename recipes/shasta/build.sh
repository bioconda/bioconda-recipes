#!/bin/bash

mkdir -p ${PREFIX}/bin

mv ${PKG_NAME}-Linux-${PKG_VERSION} shasta
chmod +x shasta
cp shasta ${PREFIX}/bin/shasta
