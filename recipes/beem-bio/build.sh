#!/bin/bash

set -xe

make CC=${CXX} BeEM

cp BeEM ${PREFIX}/bin 
