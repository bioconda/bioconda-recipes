#!/bin/bash

mkdir -p ${PREFIX}/bin

cp *.R ${PREFIX}/bin
cp *.sh ${PREFIX}/bin
cp *.bats ${PREFIX}/bin

chmod +x ${PREFIX}/bin/*.R
chmod +x ${PREFIX}/bin/*.sh
chmod +x ${PREFIX}/bin/*.bats
