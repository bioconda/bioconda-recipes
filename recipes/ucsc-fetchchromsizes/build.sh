#!/bin/bash

mkdir -p $PREFIX/bin
cp kent/src/utils/userApps/fetchChromSizes $PREFIX/bin
chmod +x $PREFIX/bin/fetchChromSizes
