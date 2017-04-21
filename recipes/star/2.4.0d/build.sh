#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing STAR for OSX."
    
    rm STAR STARstatic
    
    # This gave problems
    sed -i.bak 's/.fopenmp//g' Makefile
    
    # Linkers need to be after the objects
    sed -i.bak 's/STAR $(CCFLAGS) $(LDFLAGS) $(OBJECTS)/STAR $(CCFLAGS) $(OBJECTS) $(LDFLAGS)/g' Makefile
    
    # Include stdlib
    sed -i.bak '1i\
using namespace std;\
' *.cpp
    
    make STARforMac
    
    mkdir -p $PREFIX/bin
    
    mv STAR $PREFIX/bin
    chmod +x $PREFIX/bin/STAR
else 
    echo "Installing STAR for UNIX/Linux."
    mkdir -p $PREFIX/bin
    
    mv STAR $PREFIX/bin
    mv STARstatic $PREFIX/bin

    chmod +x $PREFIX/bin/STARstatic
    chmod +x $PREFIX/bin/STAR
fi
