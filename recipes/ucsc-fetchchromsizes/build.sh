#!/bin/bash

mkdir -p $PREFIX/bin

cp -f kent/src/utils/userApps/fetchChromSizes $PREFIX/bin
chmod 0755 $PREFIX/bin/fetchChromSizes
