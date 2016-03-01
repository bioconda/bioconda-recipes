#!/bin/bash

ln -sf $PREFIX/lib/RayPlatform RayPlatform
make
cp -R Ray $PREFIX/bin/
find scripts -type f \( -name "*.sh" -o -name "*.py" \) -exec cp {} $PREFIX/bin/ \;
