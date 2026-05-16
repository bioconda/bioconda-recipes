#!/usr/bin/env bash

# download repo
wget https://github.com/flu-crew/rf-net-2/archive/refs/heads/main.zip

# unzip .jar file
unzip main.zip -d ./
unzip rf-net-2-main/RF-Net-2.0.4.zip -d ./
rm -r rf-net-2-main/

# copy .jar file and dependencies to a bin folder
mkdir -p $PREFIX/bin/
cp RF-Net-2.0.4/RF-Net-2.0.4.jar $PREFIX/bin/
cp -r RF-Net-2.0.4/dependencies $PREFIX/bin/
rm -r RF-Net-2.0.4/ __MACOSX/
