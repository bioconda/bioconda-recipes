#!/bin/bash

curl -SL https://github.com/dooguypapua/eKLIPse/archive/refs/heads/master.zip -o eklipse.zip

unzip -d eklipse eklipse.zip
cd eklipse
chmod a+x *
mkdir -p "${PREFIX}/bin"
cp *.py "${PREFIX}/bin/."