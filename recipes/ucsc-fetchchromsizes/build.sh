#!/bin/bash

mkdir -p $PREFIX/bin
if [ "$(uname)" == "Darwin" ]; then
    cp fetchChromSizes "$PREFIX/bin"
else
    cp kent/src/utils/userApps/fetchChromSizes $PREFIX/bin
fi
    chmod +x $PREFIX/bin/fetchChromSizes
