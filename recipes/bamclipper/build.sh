#!/bin/bash

chmod +x *.pl
chmod +x *.sh

mkdir -p ${PREFIX}/bin
cp *.pl ${PREFIX}/bin
cp *.sh ${PREFIX}/bin
