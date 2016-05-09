#!/bin/bash

mv * "$PREFIX/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh "$PREFIX/setup.sh"
