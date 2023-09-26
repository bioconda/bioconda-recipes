#!/bin/bash

BIN=${PREFIX}/bin
mkdir -p ${BIN}

make
cp dupsifter ${BIN}
