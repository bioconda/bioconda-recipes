#!/bin/bash

chmod +x install.command
./install.command

mkdir -p ${PREFIX}/bin
cp $SRC_DIR/bin/*  ${PREFIX}/bin
