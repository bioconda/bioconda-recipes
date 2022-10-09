#!/bin/bash

./configure --prefix=$PREFIX
make
for f in scripts/*.sh; do
    sed -i.bak "s#/usr/bin/bash#/bin/bash#g" $f
done
for f in scripts/*.bash; do
    sed -i.bak "s#/usr/bin/bash#/bin/bash#g" $f
done
make install
