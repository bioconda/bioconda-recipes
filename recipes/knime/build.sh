#!/bin/bash

target=$PREFIX/share/knime-$KNIME_VERSION
mkdir -p $target
mkdir -p $PREFIX/bin

cp -R * $target/

ln -s $target/knime $PREFIX/bin
chmod 0755 "${PREFIX}/bin/knime"

