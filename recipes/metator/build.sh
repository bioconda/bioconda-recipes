#!/bin/bash
ls -l 
ls -l external/ 

echo "################### FIRST INSTALL OF METATOR #################"
echo "###################"
echo "###################"
echo "###################"


$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv


echo "###################"
echo "###################"
echo "###################"

ls -l 
ls -l external/ 
ls -l bin/
