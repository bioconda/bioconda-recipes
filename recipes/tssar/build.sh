#!/bin/bash

mkdir -p $PREFIX/bin

install -v -m 0755 TSSAR $PREFIX/bin
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/TSSAR
rm -rf $PREFIX/bin/*.bak
