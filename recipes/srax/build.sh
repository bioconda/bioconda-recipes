#!/bin/bash

set -e
./sraX --version
cp -r * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/sraXlib/*
chmod u+rwx $PREFIX/bin/*
