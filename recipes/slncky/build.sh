#!/bin/bash
cp -R $SRC_DIR/* $PREFIX
cd $PREFIX
chmod a+x slncky.v1.0
ln slncky.v1.0 slncky
pwd
ls -l
