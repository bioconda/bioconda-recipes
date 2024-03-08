#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing KPop for OSX."
else 
    echo "Installing KPop for Linux"
fi

mkdir -p $PREFIX/bin
cp $SRC_DIR/KPop* $PREFIX/bin

chmod +x $PREFIX/bin
chmod +x $PREFIX/bin/KPop*  