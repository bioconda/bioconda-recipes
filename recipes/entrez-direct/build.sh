#!/bin/bash

mv * "$PREFIX/bin/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh ${PREFIX}/bin/setup.sh

