#!/bin/bash
TMP=$(mktemp -d)
cd $TMP
wget https://github.com/Ding-RNA-Lab/Sfold/archive/df189e0fa5b4e64c0d16d4a7c40b3f95a15352cc.zip
unzip df189e0fa5b4e64c0d16d4a7c40b3f95a15352cc.zip
./Sfold-df189e0fa5b4e64c0d16d4a7c40b3f95a15352cc/configure
export PATH=$PATH:${PREFIX}/bin