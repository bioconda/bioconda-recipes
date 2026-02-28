#!/bin/bash
mkdir -p ${PREFIX}/bin
make CC="${CC} -fcommon"
cp shustring ${PREFIX}/bin/
