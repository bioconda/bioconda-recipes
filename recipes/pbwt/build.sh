#!/bin/bash
git clone https://github.com/richarddurbin/pbwt
git checkout 64c4ffa7880db5f85b53ccbd7e530ec4b95ea4ba
sed -i.bak 's/$(HTSLIB)/-lhts/' Makefile
make
cp pbwt $PREFIX/bin

