#!/bin/bash
echo "Installing OpenCRAVAT core package..."
"$PYTHON" -m pip install . -vv
echo "Done installing OpenCRAVAT core package"
#echo "Installing base modules..."
#oc module install-base
#echo "Done installing base modules"
