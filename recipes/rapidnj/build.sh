#!/bin/sh

make
install -d ${PREFIX}/bin
install bin/rapidnj ${PREFIX}/bin
