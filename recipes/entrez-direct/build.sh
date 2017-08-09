#!/bin/bash

mv * "$PREFIX/bin/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
cd ${PREFIX}/bin/
sh "setup.sh"
