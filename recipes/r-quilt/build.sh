#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

cd $SRC_DIR/QUILT

$R CMD INSTALL --build --install-tests .