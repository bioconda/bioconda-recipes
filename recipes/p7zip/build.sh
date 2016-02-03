#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

make all_test

sed -i "s|#! /bin/sh|#!/bin/bash|" install.sh
sed -i "s|DEST_HOME=.*|DEST_HOME=$PREFIX|" install.sh
./install.sh

rm -r $PREFIX/man
rm -r $PREFIX/share

