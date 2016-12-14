#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing STAR for OSX."
    rm STAR STARstatic
    make STARforMac
    
    mkdir -p $PREFIX/bin
    chmod -R +x $PREFIX/bin
    
    mv STARforMac $PREFIX/bin
    ln -s $PREFIX/bin/STARforMac $PREFIX/bin/STAR

    chmod +x $PREFIX/bin/STARforMac
else 
    echo "Installing STAR for UNIX/Linux."
    mkdir -p $PREFIX/bin
    
    ls -alsh
    mv STAR $PREFIX/bin
    mv STARstatic $PREFIX/bin
    
    ls -alsh $PREFIX/bin

    chmod +x $PREFIX/bin/STARstatic
    chmod +x $PREFIX/bin/STAR
fi
