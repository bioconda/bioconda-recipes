#!/bin/bash
mkdir -p $PREFIX/bin

cp upload_run.py $PREFIX/bin/irida-uploader
cp -r config $PREFIX/bin
cp -r core $PREFIX/bin
cp -r api $PREFIX/bin
cp -r model $PREFIX/bin
cp -r parsers $PREFIX/bin
cp -r progress $PREFIX/bin

chmod +x $PREFIX/bin/irida-uploader
