#!/bin/bash

chmod +x $SRC_DIR/build/*

export PRFX=$PREFIX
make
make install prefix=$PREFIX