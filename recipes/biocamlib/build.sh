#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing BiOCamLib for OSX."
else 
    echo "Installing BiOCamLib for Linux"
fi

mkdir -p $PREFIX/bin
cp $SRC_DIR/FASTools $PREFIX/bin
cp $SRC_DIR/Parallel $PREFIX/bin
cp $SRC_DIR/Octopus $PREFIX/bin
cp $SRC_DIR/RC $PREFIX/bin

chmod +x $PREFIX/bin/FASTools
chmod +x $PREFIX/bin/Parallel
chmod +x $PREFIX/bin/Octopus
chmod +x $PREFIX/bin/RC