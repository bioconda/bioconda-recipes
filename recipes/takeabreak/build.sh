#!/bin/bash

mkdir -p ${PREFIX}/bin

# installation
sh INSTALL

# copy binary
cp build/bin/TakeABreak ${PREFIX}/bin
