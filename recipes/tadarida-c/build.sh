#!/bin/bash

mkdir -p "$PREFIX/bin"
cp tadaridaC.r "$PREFIX/bin"
PATH=$PATH:$PREFIX/bin