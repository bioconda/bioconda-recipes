#!/bin/bash

set -e

mkdir -p ${PREFIX}/bin
cp -r sraXlib ${PREFIX}/bin
cp sraX ${PREFIX}/bin

chmod -R a+rx $PREFIX/bin
