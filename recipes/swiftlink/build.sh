#!/bin/sh

cd src
make
cd -

cp -v src/swift $PREFIX/bin/
