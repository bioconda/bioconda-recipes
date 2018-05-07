#!/bin/bash

make

cp *.py ${PREFIX}/bin/
cp *.sh ${PREFIX}/bin/
cp bsmap ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/*
