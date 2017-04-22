#!/bin/bash

echo "Installing STAR for UNIX/Linux."
mkdir -p $PREFIX/bin

mv STAR $PREFIX/bin
mv STARstatic $PREFIX/bin

chmod +x $PREFIX/bin/STARstatic
chmod +x $PREFIX/bin/STAR
