#!/bin/bash

sh build.sh
mv * "$PREFIX/bin/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh ${PREFIX}/bin/setup.sh

