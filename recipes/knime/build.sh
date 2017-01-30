#!/bin/bash

target=$PREFIX/lib/knime
mkdir -p $target
mkdir -p $PREFIX/bin

chmod +x ./knime

cp -R * $target
ln -s $target/knime $PREFIX/bin/knime

