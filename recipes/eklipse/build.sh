#!/bin/bash

curl -SL https://github.com/dooguypapua/eKLIPse/archive/refs/heads/master.zip -o eklipse.zip

unzip -d eklipse eklipse.zip
cd eklipse
mv eKLIPse-master eklipse
chmod a+x eklipse/*
chmod a+x eklipse
mkdir -p "${PREFIX}/bin"
cp -r eKLIPse-master/* "${PREFIX}/bin/."