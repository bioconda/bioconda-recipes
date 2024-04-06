#!/bin/bash

mkdir -p $PREFIX/bin
cp k8-$(uname -m)-$(uname -s) $PREFIX/bin/k8
