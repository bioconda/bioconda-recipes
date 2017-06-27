#!/bin/bash

mv tools $PREFIX/tools
mv app "${PREFIX}/bin"
cp libexec/* "${PREFIX}/bin/"
