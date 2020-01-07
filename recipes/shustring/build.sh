#!/bin/bash
mkdir -p ${PREFIX}/bin
make CC=${CC}
cp shustring ${PREFIX}/bin/
