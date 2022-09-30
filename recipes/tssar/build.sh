#!/bin/bash

mkdir -p $PREFIX/bin

cp TSSAR $PREFIX/bin
chmod +x $PREFIX/bin/TSSAR
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/TSSAR
