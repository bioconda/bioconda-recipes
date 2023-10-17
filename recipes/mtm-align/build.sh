#!/bin/bash
set -ex

wget http://yanglab.nankai.edu.cn/mTM-align/version/mTM-align.tar.bz2

tar xjf mTM-align.tar.bz2
cd mTM-align/src/
make

mv mTM-align ${PREFIX}/mtm-align
