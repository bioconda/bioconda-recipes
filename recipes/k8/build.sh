#!/bin/bash

mkdir -p $PREFIX/bin

cp k8-`uname -s|tr [A-Z] [a-z]` $PREFIX/bin/k8
