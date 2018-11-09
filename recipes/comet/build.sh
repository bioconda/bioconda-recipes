#!/usr/bin/env bash

chmod 755 comet.2018012.linux.exe
cp comet.2018012.linux.exe ${PREFIX}/bin/comet
cd ${PREFIX}/bin/
ln -s comet comet.exe
