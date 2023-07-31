#!/bin/bash

mv third_party/Unity-5e9acef74faffba86375258d822f49d0b1173b5e third_party/Unity
mv third_party/uthash-8e67ced1d1c5bd8141c542a22630e6de78aa6b90 third_party/uthash
make
mkdir -p $PREFIX/bin
mv conifer $PREFIX/bin