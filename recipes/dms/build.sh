#!/bin/bash

mkdir -p ${PREFIX}/bin

if [ `uname` == Darwin ]; then
    echo "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm111111111111111111111111"
    brew install gcc
    make
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
else
    echo "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn2222222222222222222222222"
    make
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
