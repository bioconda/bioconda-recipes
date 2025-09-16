#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

./waf configure

./waf

cp build/apps/bgenix ${PREFIX}/bin
cp build/apps/cat-bgen ${PREFIX}/bin
cp build/apps/edit-bgen ${PREFIX}/bin