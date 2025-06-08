#!/bin/bash

set -xe

make CC=${CXX} BeEM

mkdir -p "${PREFIX}/bin"
cp BeEM "${PREFIX}/bin"
