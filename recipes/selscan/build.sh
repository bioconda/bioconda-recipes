#!/bin/sh

cd src

make

install -d "${PREFIX}/bin"
install \
    selscan \
    norm \
    "${PREFIX}/bin/"
